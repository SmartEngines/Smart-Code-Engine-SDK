import http.server
import http.cookiejar
import io
import socket
from http import HTTPStatus

import ssl
import os
import zlib
server_address = ('0.0.0.0', 4443)


hostname = socket.gethostname()
local_ip = socket.gethostbyname(hostname)

print("Open https://localhost:4443/samples/codeengine_sample_wasm/sample.html")
print(f'Open https://{local_ip}:4443/samples/codeengine_sample_wasm/sample.html')


# os.chdir("./dist/")

compressed_types = [
    "application/javascript",
    "application/wasm",
    "application/json",
    "application/x-javascript",
    "application/xml",
    "font/eot",
    "font/opentype",
    "image/bmp",
    "image/svg+xml",
    "text/css",
    "text/html",
    "text/javascript",
    "text/plain"
]

# Generators for HTTP compression
def _zlib_producer(fileobj, wbits):
    bufsize = 2 << 17
    producer = zlib.compressobj(wbits=wbits)
    with fileobj:
        while True:
            buf = fileobj.read(bufsize)
            if not buf:  # end of file
                yield producer.flush()
                return
            yield producer.compress(buf)


def _gzip_producer(fileobj):
    """Generator for gzip compression."""
    return _zlib_producer(fileobj, 31)


def _deflate_producer(fileobj):
    """Generator for deflate compression."""
    return _zlib_producer(fileobj, 15)

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        '': 'application/octet-stream',
        '.manifest': 'text/cache-manifest',
        '.html': 'text/html',
        '.png': 'image/png',
        '.jpg': 'image/jpg',
        '.svg':	'image/svg+xml',
        '.css':	'text/css',
        '.js': 'application/x-javascript',
        '.wasm': 'application/wasm',
        '.json': 'application/json',
        '.xml': 'application/xml',
    }

    compressions = {}
    if zlib:
        compressions = {
            'deflate': _deflate_producer,
            'gzip': _gzip_producer,
            'x-gzip': _gzip_producer  # alias for gzip
        }

    def do_GET(self):
        """Serve a GET request."""
        if self.path == '/':
            self.path = 'sample.html'

        if f := self.send_head():
            try:
                if hasattr(f, "read"):
                    self.copyfile(f, self.wfile)
                else:
                    for data in f:
                        self.wfile.write(data)
            finally:
                f.close()

    def send_head(self):
        path = self.translate_path(self.path)
        f = None
        try:
            f = open(path, 'rb')
        except OSError:
            self.send_error(HTTPStatus.NOT_FOUND, "File not found")
            return None

        ctype = self.guess_type(path)

        try:
            fs = os.fstat(f.fileno())
            content_length = fs[6]

            self.send_response(HTTPStatus.OK)
            self.send_header("Content-type", ctype)

            if ctype not in compressed_types:
                self.send_header("Content-Length", str(content_length))
                self.end_headers()
                return f

            # Use HTTP compression if possible

            # Get accepted encodings ; "encodings" is a dictionary mapping
            # encodings to their quality ; eg for header "gzip; q=0.8",
            # encodings["gzip"] is set to 0.8
            accept_encoding = self.headers.get_all("Accept-Encoding", ())
            encodings = {}
            for accept in http.cookiejar.split_header_words(accept_encoding):
                params = iter(accept)
                encoding = next(params, ("", ""))[0]
                quality, value = next(params, ("", ""))
                if quality == "q" and value:
                    try:
                        q = float(value)
                    except ValueError:
                        # Invalid quality : ignore encoding
                        q = 0
                else:
                    q = 1  # quality defaults to 1
                if q:
                    encodings[encoding] = max(encodings.get(encoding, 0), q)

            compressions = set(encodings).intersection(self.compressions)
            compression = None
            if compressions:
                # Take the encoding with highest quality
                compression = max((encodings[enc], enc)
                                  for enc in compressions)[1]
            elif '*' in encodings and self.compressions:
                # If no specified encoding is supported but "*" is accepted,
                # take one of the available compressions.
                compression = list(self.compressions)[0]
            if compression:
                # If at least one encoding is accepted, send data compressed
                # with the selected compression algorithm.
                producer = self.compressions[compression]
                self.send_header("Content-Encoding", compression)
                if content_length < 2 << 18:
                    # For small files, load content in memory
                    with f:
                        content = b''.join(producer(f))
                    content_length = len(content)
                    f = io.BytesIO(content)
                else:
                    self.end_headers()
                    return producer(f)

            self.send_header("Content-Length", str(content_length))
            self.end_headers()
            return f
        except:
            f.close()
            raise

    def end_headers(self):
        # Include additional response headers here. CORS for example:
        self.send_header('Access-Control-Allow-Origin', '*')
        
        # Get access to SharedArrayBuffer require an isolated origin for security reasons.
        # https://web.dev/articles/webassembly-threads#sharedarraybuffer
        # Check out using COOP and COEP:
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        http.server.SimpleHTTPRequestHandler.end_headers(self)


httpd = http.server.ThreadingHTTPServer(server_address, CORSHTTPRequestHandler)
ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.check_hostname = False
ctx.load_cert_chain(certfile='samples/codeengine_sample_wasm/localhost.pem')  # with key inside
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
httpd.serve_forever()
