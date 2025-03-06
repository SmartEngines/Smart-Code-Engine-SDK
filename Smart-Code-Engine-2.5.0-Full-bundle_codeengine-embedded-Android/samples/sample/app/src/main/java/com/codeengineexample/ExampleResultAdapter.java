package com.codeengineexample;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.smartengines.R;
import com.smartengines.ResultStore;

import java.util.ArrayList;
import java.util.Map;




public  class ExampleResultAdapter extends BaseAdapter {
    private static final int TYPE_ITEM = 0;
    private static final int TYPE_SECTION = 1;
    private static final int TYPE_IMG = 2;

    private Context _context;

    ArrayList <Object> mData = new ArrayList<>();
    ArrayList <String> types = new ArrayList<>();

    private LayoutInflater mInflater;

    public ExampleResultAdapter(Context context) {

        _context = context;
        mInflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    public void clear() {
        mData.clear();
        types.clear();
        notifyDataSetChanged();

    }

    public void addItem(Pair<String, ResultStore.FieldInfo> item, String type) {
        mData.add(item);
        types.add(type);
        notifyDataSetChanged();
    }

    public void addItem(String item, String type) {
        mData.add(item);
        types.add(type);
        notifyDataSetChanged();
    }

    @Override
    public int getItemViewType(int position) {

        switch (types.get(position)) {
            case "field":
                return TYPE_ITEM;
            case "section":
                return TYPE_SECTION;
            case "image":
                return TYPE_IMG;
        }
        return 0;
    }

    @Override
    public int getViewTypeCount() {
        return 4;
    }

    @Override
    public int getCount() {
        return mData.size();
    }

    @Override
    public Object getItem(int position) {
        return mData.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        int rowType = getItemViewType(position);
//        System.out.println(rowType);

        // Choose template
        if (convertView == null) {

            switch (rowType) {
                case TYPE_ITEM:
                    convertView = mInflater.inflate(R.layout.result_row_field, null);
                    break;
                case TYPE_SECTION:
                    convertView = mInflater.inflate(R.layout.result_header, null);
                    break;
                case TYPE_IMG:
                    convertView = mInflater.inflate(R.layout.result_row_image, null);
                    break;
            }
        }

        // Fill template
        switch (rowType) {
            case TYPE_ITEM:

                Pair <String, ResultStore.FieldInfo> el = (Pair<String, ResultStore.FieldInfo>) mData.get(position);

                ((TextView) convertView.findViewById(R.id.name)).setText(el.first);
                ((TextView) convertView.findViewById(R.id.val)).setText(el.second.value);
                ((TextView) convertView.findViewById(R.id.isAccepted)).setText(String.valueOf(el.second.isAccepted));

                LinearLayout l = convertView.findViewById(R.id.attributes);
                l.removeAllViews();

                for (Map.Entry<String, String> attr : el.second.attr.entrySet()) {
                    TextView at = new TextView(_context);
                    at.setText(attr.getKey() +":"+attr.getValue());
                    at.setTextSize(10);
                    l.addView(at);
                }

                break;
            case TYPE_IMG:
                Pair<String, ResultStore.FieldInfo> img = (Pair<String, ResultStore.FieldInfo>) mData.get(position);

                ((TextView) convertView.findViewById(R.id.name)).setText(img.first);
                byte[] bytes = Base64.decode(img.second.value, Base64.DEFAULT);
                Bitmap bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                ((ImageView) convertView.findViewById(R.id.imageView)).setImageBitmap(bmp);

                LinearLayout ll = convertView.findViewById(R.id.imgAttributes);
                ll.removeAllViews();

                for (Map.Entry<String, String> attr : img.second.attr.entrySet()) {
                    TextView at = new TextView(_context);
                    at.setText(attr.getKey() +":"+attr.getValue());
                    at.setTextSize(10);
                    ll.addView(at);
                }

                break;

            case TYPE_SECTION:
                ((TextView) convertView.findViewById(R.id.header)).setText(mData.get(position).toString());
                break;
        }

        return convertView;
    }

}

