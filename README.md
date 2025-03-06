# Smart-Code-Engine SDK Overview

This is a collection of DEMO builds of Smart Code Engine SDK developed by Smart Engines. The SDK examples can be used to demonstrate the integration possibilities and understand the basic object recognition workflows.


  * [:warning: Personalized signature :warning:](#warning-personalized-signature-warning)
  * [Troubleshooting and help](#troubleshooting-and-help)
  * [General Usage Workflow](#general-usage-workflow)
  * [Smart Code Engine SDK Overview](#smart-code-engine-sdk-overview)
    - [Header files, namespaces, and modules](#header-files-namespaces-and-modules)
    - [Barcode recognition](#barcode-recognition)
    - [Bank card recognition](#bank-card-recognition)
    - [MRZ recognition](#mrz-recognition)
    - [Codified text line recognition](#codified-text-line-recognition)
    - [Container recognition](#container-recognition)
    - [Payment details recognition](#payment-details-recognition)
    - [Universal Pay](#universal-pay)
    - [Licence plate recognition](#licence-plate-recognition)
    - [Code documentation](#code-documentation)   
    - [Exceptions](#exceptions)
    - [Factory methods and memory ownership](#factory-methods-and-memory-ownership)
  * [Session options](#session-options)
    - [Global options](#global-options)
  * [Processing Feedback](#processing-feedback)
  * [Java API Specifics](#java-api-specifics)
    - [Object deallocation](#object-deallocation)
    - [Feedback scope](#feedback-scope)

## :warning: Personalized signature :warning:

All Smart Code Engine SDK clients are required to use a personalized signature for starting a session. The signature is validated offline and locks to the copy of the native library, thus ensures that only an authorized client may use it. The signature is a string with 256 characters.

You will need to manually copy the signature string and pass it as an argument for the `SpawnSession()` method ([see item 6 below]). Do NOT keep the signature in any asset files, only inside code. If possible, clients are encouraged to keep the signature in a controlled server and load it into the application via a secure channel, to ensure that signature and the library are separated.

## Troubleshooting and help

To resolve issue that you might be facing we recommend to do the following:

* Carefully read in-code documentation in API and samples and documentation in .pdf and .html, including this document
* Check out the code details / compilation flags etc. in the sample code and projects
* Read exception messages if exception is thrown - it might contain usable information

But remember:
* You are always welcome to ask for help at `support@smartengines.com` (or your sales manager's email) no matter what

## General Usage Workflow

1. Create `CodeEngine` instance:

    ```cpp
    // C++
    std::unique_ptr<se::code::CodeEngine> engine(
        se::code::CodeEngine::CreateFromEmbeddedBundle(true));
    ```

    ```java
    // Java
    CodeEngine engine = CodeEngine.CreateFromEmbeddedBundle(true);
    ```

    Configuration process might take a while but it only needs to be performed once during the program lifetime. Configured `CodeEngine` is used to spawn CodeEngineSessions which have actual recognition methods.

    The first parameter to the `CreateFromEmbeddedBundle()` method is a boolean flag for enabling lazy configuration (`true` by default). If lazy configuration is enabled, some of the internal structured will be allocated and initialized only when first needed. If you disable the lazy configuration, all the internal structures and components will be initialized in the `CreateFromEmbeddedBundle()` method.

2. Create `CodeEngineSessionSettings` from configured `CodeEngine`:

    ```cpp
    // C++
    std::unique_ptr<se::code::CodeEngineSessionSettings> settings(
        engine->GetDefaultSessionSettings());
    ```

    ```java
    // Java
    CodeEngineSessionSettings settings = engine.GetDefaultSessionSettings();
    ```

    Note, that `CodeEngine::GetDefaultSessionSettings()` is a factory method and returns an allocated pointer. You are responsible for deleting it.

3. Specify recognition engines to run:

    ```cpp
    // C++
    settings->SetOption("barcode.enabled", "true"); // Enabling barcode recognition in this session
    ```

    ```java
    // Java
    settings.SetOption("barcode.enabled", "true"); // Enabling barcode recognition in this session
    ```

4. Specify additional session options (not required):

    ```cpp
    // C++
    settings->SetOption("barcode.COMMON.enabled", "true"); // Enabling all barcode symbologies recognition in this session
    ```

    ```java
    // Java
    settings.SetOption("barcode.COMMON.enabled", "true"); // Enabling all barcode symbologies recognition in this session
    ```

    See more about options in [Session Options](#session-options).

5. Subclasses `CodeEngineWorkflowFeedback`, `CodeEngineVisualizationFeedback` and implement callbacks (not required):

    ```cpp
    // C++
    class MyWorkflowFeedback : public se::code::CodeEngineWorkflowFeedback { /* callbacks */ };
    class MyVisualizationFeedback : public se::code::CodeEngineVisualizationFeedback { /* callbacks */ };

    // ...

    MyWorkflowFeedback my_workflow_feedback;
    MyVisualizationFeedback my_visualization_feedback;
    ```

    ```java
    // Java
    class MyWorkflowFeedback extends CodeEngineWorkflowFeedback { /* callbacks */ }
    class MyVisualizationFeedback extends CodeEngineVisualizationFeedback { /* callbacks */ }

    // ...

    MyWorkflowFeedback my_workflow_feedback = new MyWorkflowFeedback();
    MyVisualizationFeedback my_visualization_feedback = new MyVisualizationFeedback();
    ```

    See more about callbacks in [Processing Feedback](#processing-feedback).

6. Spawn CodeEngineSession:

    ```cpp
    // C++
    const char* signature = "... YOUR SIGNATURE HERE ...";
    std::unique_ptr<se::code::CodeEngineSession> session(
        engine->SpawnSession(*settings, signature, &my_workflow_feedback, &my_visualization_feedback));
    ```

    ```java
    // Java
    String signature = "... YOUR SIGNATURE HERE ...";
    CodeEngineSession session = engine.SpawnSession(
        settings, signature, my_workflow_feedback, my_visualization_feedback); 
    ```

    For explanation of signatures, [see above](#warning-personalized-signature-warning).

7. Create an `Image` object which will be used for processing:

    ```cpp
    // C++
    std::unique_ptr<se::common::Image> image(
        se::common::Image::FromFile(image_path)); // Loading from file
    ```

    ```java
    // Java
    Image image = Image.FromFile(image_path);
    ```

8. Call `Process(...)` method for processing the image:

    ```cpp
    // C++
    const se::code::CodeEngineResult& result = session->Process(*image);
    ```

    ```java
    // Java
    CodeEngineResult result = session.Process(image);
    ```

    When performing recognition in video stream you might want to process frames coming from the stream until `result.IsTerminal()` is `true`.

9. Use `CodeEngineResult` fields to extract recognized information:

    ```cpp
    // C++
    for (auto it_obj = result.ObjectsBegin(); it_obj != result.ObjectsEnd(); ++it_obj) {
        const se::code::CodeObject& code_object = it_obj.GetValue();

        std::string object_type = code_object.GetTypeStr(); // Type of the codified object in string format
        bool is_accepted = code_object.IsAccepted(); // Accept flag value

        for (auto it_field = code_object.FieldsBegin();
             it_field != code_object.FieldsEnd(); ++it_field) {
            const se::code::CodeField &code_field = it_field.GetValue();

            std::string code_field_name = code_field.Name(); // Code field name
            if (code_field.HasOcrStringRepresentation())
                std::string ocr_string = code_field.GetOcrString()
                    .GetFirstString()
                    .GetCStr(); // UTF-8 string representation of the recognized field
        }
    }
    ```

    ```java
    // Java
    for (CodeObjectsMapIterator it_obj = result.ObjectsBegin(); 
         !it_obj.Equals(result.ObjectsEnd()); it_obj.Advance()) {
        CodeObject code_object = it_obj.GetValue();

        String object_type = code_object.GetTypeStr(); // Type of the codified object in string format
        boolean is_accepted = code_object.IsAccepted(); // Accept flag value
        
        for (CodeFieldsMapIterator it_field = code_object.FieldsBegin();
             !it_field.Equals(code_object.FieldsEnd()); it_field.Advance()) {
            CodeField code_field = it_field.GetValue();

            String code_field_name = code_field.Name(); // Code field name
            if (code_field.HasOcrStringRepresentation())
                String ocr_string = code_field.GetOcrString().GetFirstString().GetCStr(); // UTF-8 string representation of the recognized field
    }
    ```

## Smart Code Engine SDK Overview

#### Header files, namespaces, and modules

Common classes, such as Point, OcrString, Image, etc. are located within `se::common` namespace and are located within a `secommon` directory:

```cpp
// C++
#include <secommon/se_export_defs.h>      // This header contains export-related definitions of Smart Engines libraries
#include <secommon/se_exceptions.h>       // This header contains the definition of exceptions used in Smart Engines libraries
#include <secommon/se_geometry.h>         // This header contains geometric classes and procedures (Point, Rectangle, etc.)
#include <secommon/se_image.h>            // This header contains the definition of the Image class 
#include <secommon/se_string.h>           // This header contains the string-related classes (MutableString, OcrString, etc.)
#include <secommon/se_strings_iterator.h> // This header contains the definition of string-targeted iterators
#include <secommon/se_serialization.h>    // This header contains auxiliary classes related to object serialization

#include <secommon/se_common.h>           // This is an auxiliary header which simply includes all of the above
```

The same common classes in Java API are located within `com.smartengines.common` module:

```java
// Java
import com.smartengines.common.*; // Import all se::common classes
```

Main Smart Code Engine classes are located within `se::code` namespaces and are located within an `codeengine` directory:

```cpp
// C++
#include <codeengine/code_engine.h>                  // Contains CodeEngine class definition
#include <codeengine/code_engine_session.h>          // Contains CodeEngineSession class definition 
#include <codeengine/code_engine_session_settings.h> // Contains CodeEngineSessionSettings class definition
#include <codeengine/code_engine_result.h>           // Contains CodeEngineResult class definition
#include <codeengine/code_engine_feedback.h>         // Contains CodeEngineWorkflowFeedback and CodeEngineVisualizationFeedback, as well as associated containers
#include <codeengine/code_object_field.h>            // Contains CodeField class definition
#include <codeengine/code_object.h>                  // Contains CodeObject class definition
```

The same classes in Java API are located within `com.smartengines.code` module:

```java
// Java
import com.smartengines.code.*; // Import all se::code classes
```

#### Barcode recognition
The `barcode` engine recognizes barcodes on the given set of frames.
By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("barcode.enabled", "true");
```

:warning: By default all barcode symbologies are disabled.
To enable specific barcode symbology set the corresponding session option:

```c++
settings->SetOption("barcode.<symbology>.enabled", "true");
```
The full list of supported symbologies is the following:
`CODABAR`, `CODE_39`, `CODE_93`, `CODE_128`, `EAN_8`, `EAN_13_UPC_A`, `ITF`, `UPC_E`, `AZTEC`, `PDF_417`, `QR_CODE`, `DATA_MATRIX`, `MICRO_QR`, `MICRO_PDF_417`.

There is helpful shorthand to enable the commonly used set of barcodes: 
```c++
settings->SetOption("barcode.COMMON.enabled", "true")
```
It consists of the following list of symbologies: `CODABAR`, `CODE_39`, `CODE_93`, `CODE_128`, `EAN_8`, `EAN_13_UPC_A`, `ITF`, `UPC_E`, `AZTEC`, `PDF_417`, `QR_CODE`, `DATA_MATRIX`.

To enable the full set of symbologies the `ALL` shorthand can be used:
```c++
settings->SetOption("barcode.ALL.enabled", "true")
```
:warning: This is not recommended due to performance and recognition accuracy issues. 

The recognition result for barcode contains two code fields: `bytes` and `value`.
The `bytes` field contains the content representation in `base64` format.
The `value` field contains the human readable barcode content if possible, otherwise it contains the copy of the `bytes` field data.
The attribute `encoding` of this field specifies which type of content it contains.
Common values are `utf8` and `base64`.

There are three main scenarios for barcode recognition: `focused`, `anywhere` or `dummy`.
The `focused` mode is designed to process barcodes using handheld camera recognition in videostream when the code occupies the significant area of the source image.
The `anywhere` mode is designed to process barcodes on any image in any location. This is much more resource consuming operation. It can be used to process any image from the gallery.
The `dummy` mode is mainly used when location of barcode is predefined.
To enable the required mode set the corresponding session option:
```c++
settings->SetOption("barcode.roiDetectionMode", "focused");
```
By default, the barcode feedmode is set to 'single' - barcode recognition stops after one barcode is found. To recognize several barcodes, set feedmode to 'sequence'.
```c++
settings->SetOption("barcode.feedMode", "sequence");
```

There is a set of stuctured text messages commonly encoded using barcodes.
You can provide a hint which structured message you expect to meet in your session.
This hint is denoted as `preset` and populates the set of fields in which the content is splitted.
By default, no preset is enabled.
To enable a preset you must set the special session option:
```c++
settings->SetOption("barcode.preset", "AAMVA");
```
The user can also enable multiple presets. In this case, the value of the session option takes the following form:
```c++
settings->SetOption("barcode.preset", "URL|PAYMENT");
```
where the option value contains a set of presets separated by a `|` sign. If a preset succeeded, `CodeField` `message_type` containing the preset's name is added to the result as well as the corresponding list of `CodeField`s.


The full list of supported presets is the following:
`AAMVA`, `GS1`, `URL`, `EMAIL`, `VCARD`, `ICALENDAR`, `PHONE`, `SMS`, `ISBN`, `WIFI`, `GEO`, `PAYMENT`.
Every preset contains its own set of fields to populate:
- `AAMVA` preset meets the `AAMVA` specification, e.g. "AAMVA_VERSION", "ANSI", "DAC" and many others.
- `GS1`: "BATCH/LOT", "EXPIRY", "GTIN", "SERIAL", "SSCC/SSCI" and others.
- `URL`: "URL".
- `EMAIL`: "Body", "Recipients", "Subject", "URL mailto", "Carbon copy" and others.
- `VCARD`: "vCard version", "ADR", "AGENT", "BDAY", "CATEGORIES", "CLASS", "LABEL", "EMAIL" and many others.
- `ICALENDAR`: "EVENT0", "EVENT1" etc. 
- `PHONE`: "Phone".
- `SMS`: "SMS_number", "Body".
- `ISBN`: "ISBN", "ISBN type", "Prefix", "Registration group".
- `WIFI`: "Authentication type", "Password", "SSID" and others.
- `GEO`: "Latitude", "Longitude", "Query".
- `PAYMENT`: "BIC", "BankName", "CorrespAcc", "Name", "PersonalAcc" and many others.


The set of barcode related options is presented in the table.
|                                   Option name |                           Value type   |           Default |                                  Descripti1on|
|:----------------------------------------------|:--------------------------------------:|:-----------------:|----------------------------------------------|
| `barcode.enabled`                             | `"true"` or `"false"`                  | false             | Enables/disables barcode recognition         |
| `barcode.ALL.enabled`                         | `"true"` or `"false"`                  | false             | Enables all barcode symbologies              |
| `barcode.COMMON.enabled`                      | `"true"` or `"false"`                  | false             | Enables common barcode symbologies           |
| `barcode.maxAllowedCodes`                     | Integer number                         | 1                 | Specifies the max number of recognized codes |
| `barcode.roiDetectionMode`                    | `"focused"`, `"anywhere"` or `"dummy"` | focused           | Specifies the ROI detection mode |
| `barcode.feedMode`                            | `"sequence"` or `"single"`             | single            | Specifies the feed mode of barcode session |
| `barcode.effortLevel`                         | `"low"`, `"normal"` or `"high"`        | normal            | Specifies the recognition effort level  |
| `barcode.<symbology>.enabled`                 | `"true"` or `"false"`                  | false             | Enables/disables given symbology        |
| `barcode.<symbology>.minMsgLen`               | Integer number                         | `1`               | The minimum length of barcode message  |
| `barcode.<symbology>.maxMsgLen`               | Integer number                         | `999`             | The maximum length of barcode message  |
| `barcode.<symbology>.checkSumPresence`        | Integer number                         | `0`               | Specifies the presence of check sum (for 1d codes) |
| `barcode.<symbology>.extendedMode`            | `"true"` or `"false"`                  |   false           | Specifies the extended mode (for 1d codes) |
| `barcode.<symbology>.barcodeColour`           | `"black"`, `"white"` or `"unknown"`    | `"unknown"`       | Specifies the expected module colour |
| `barcode.preset`                              | `preset name`                          | `none`            | Specifies the preset for the decoded barcode content interpretation |
| `barcode.preset.PAYMENT.strictSpecCompliance` | `"true"` or `"false"`                  | false             | Specifies if the `PAYMENT` preset strictly follows the corresponding specification |
| `barcode.smartPaymentBarDecoding`             | `"true"` or `"false"`                  | false        | Enables smart encoding detection for payment barcodes |
| `barcode.disableECI`                          |`"true"` or `"false"`                   | false             | Enables/disables recognition of barcodes with Extended Channel Interpretation |

The user can enable text smart encoding detection for payment barcodes which violates the specification. To achieve that you must set the special session option:
```c++
settings->SetOption("barcode.smartPaymentBarDecoding", "true");
```
If the algorithm succeeded, `CodeField` `smart_payment_bar_decoding_result` containing the encoding name is added to the result and may be used in the `PAYMENT` preset instead of following the specification. The full list of supported encodings is the following: `UTF8`, `CP1251`, `KOI8_R`, `ISO8859_5`, `CP932`.

#### Bank card recognition
The `bank_card` engine recognizes bank cards on the given set of frames.
By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("bank_card.enabled", "true");
```

There are three types of bank cards: `embossed`, `indent`, `freeform`.
`embossed` defines bank cards with embossed data pattern.
`indent` defines bank cards with intent-printed data pattern.
`freeform` defines bank cards with flat-designed data pattern, where data of interestb may be located anywhere in the card.
By default all these types are enabled.
The types of recognized bank cards could be explicitly specified using the corresponding session option: 
```c++
settings->SetOption("bank_card.embossed.enabled", "true")
```

For `embossed` and `indent` bank cards the recognition result may contain the following list of fields:
- `number` - Number of the bank card (mandatory)
- `name` - Cardholder's name
- `expiry_date` - Expiry date in format `MM/YY`
- `optional_data_0` - Additional data line in any format
- `optional_data_1` - Additional data line in any format
- `optional_data_2` - Additional data line in any format

For `freeform` bank cards the recognition result may contain the following list of fields:
- `number` - Number of the bank card
- `name` - Cardholder's name
- `expiry_date` - Expiry date in format `MM/YY`
- `iban` - IBAN number (according to [ISO 13616](https://www.iso.org/standard/41031.html))

For this engine, there are two supported capture modes: `mobile` and `anywhere`.
The capture mode determines where to find the bank card. `mobile` mode mostly addresses handheld camera recognition in videostream, while `anywhere` mode is suitable for scanned images, webcam images, and arbitrary placed bank cards.
By default the `mobile` option is enabled.

The set of bank card related options is presented in the table.
|                                   Option name |                           Value type   |           Default |                                  Description|
|:----------------------------------------------|:--------------------------------------:|:-----------------:|----------------------------------------------|
| `bank_card.enabled`                           | `"true"` or `"false"`                  | false             | Enables/disables bank card recognition         |
| `bank_card.captureMode`                           | `"mobile"` or `"anywhere"`                  | `"mobile"`             | Specifies bank card detection mode         |
| `bank_card.enableStoppers`                            | `"true"` or `"false"`                  | `"true"`             | Enables smart text fields stoppers         |
| `bank_card.extractBankCardImages`                             | `"true"` or `"false"`                  | `"false"`             | Extracts rectified bank card image and stores it in the relevant `CodeObject`        |


#### MRZ recognition
The `mrz` engine recognizes MRZ on the given set of frames according to the ICAO specification [link](https://www.icao.int/publications/pages/publication.aspx?docnum=9303).
By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("mrz.enabled", "true");
```

The recognition result contains the `full_mrz` code field alongside with the set of splitted fields which names depend on the determined MRZ type.

The `mrz` engine supports recognition of the following MRZ types.
- ICAO 9303 MRZ MRP (TD3) subtype - Machine Readable Passport, 2 lines, 44 characters each
- ICAO 9303 MRZ MRVA subtype - Machine Readable Visa - Type A, 2 lines, 44 characters each
- ICAO 9303 MRZ MRVB subtype - Machine Readable Visa - Type B, 2 lines, 36 characters each
- ICAO 9303 MRZ TD1 subtype - Machine Readable Travel Document Type 1, 3 lines, 30 characters each
- ICAO 9303 MRZ TD2 subtype - Machine Readable Travel Document Type 2, 2 lines, 36 characters each
- MRZ-like zone on Bulgarian vehicle registration certificates, 3 lines, 30 characters each
- MRZ-like zone on Swiss driving licence, 3 lines, 9 characters in the first line, 30 characters in the second and third lines
- MRZ-like zone on Ecuador ID, 3 lines, 30 characters each
- MRZ-like zone on French ID cards, 2 lines, 36 characters each
- MRZ-like zone on Kenya ID, 3 lines, 30 characters each
- MRZ-like zone on Russian national passport, 2 lines, 44 characters each
- MRZ-like zone on Russian visa, 2 lines, 44 characters each

Depending on the MRZ type, the recognition result contain a subset of code fields of the following names: `mrz_doc_type_code`, `mrz_number`, `mrz_issuer`, `mrz_proprietor`, `mrz_vehicle_number`, `mrz_line1`, `mrz_line2`, `mrz_line3`, `full_mrz`, `mrz_vin`, `mrz_id_number`, `mrz_cd_number`, `mrz_cd_bgrvrd_1`, `mrz_cd_bgrvrd_2`, `mrz_birth_date`, `mrz_name`, `mrz_nationality`, `mrz_opt_data_1`, `mrz_opt_data_2`, `mrz_last_name`, `mrz_gender`, `mrz_expiry_date`, `mrz_issue_date`, `photo`, `mrz_cd_birth_date`, `mrz_cd_composite`, `mrz_cd_expiry_date`, `mrz_cd_opt_data_2`, `mrz_authority_code`, `mrz_id_visa`, `mrz_invitation_number`, `mrz_cd_name`, `mrz_cd_invitation_number`, `mrz_cd_id_visa`, `mrz_first_name`, `mrz_cd_issue_date`,`mrz_cd_composit`.

#### Codified text line recognition
The `code_text_line` engine recognizes codified text lines, i.e. the lines with preset content.
By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("code_text_line.enabled", "true");
```

The full list of supported types is the following:
 - `phone_number`: specialized for mobile phone numbers in Russian Federation. Supported phone numbers should starting from [`"7"`, `"8"`] and consist of ABC code [`"3XX"`, `"4XX"`, `"7XX"`, `"8XX"`] or DEF code [`"9XX"`]. The numbers which are started from DEF code (10 digits) are also supported. Both printed and handwritten text lines are supported.
 - `phone_number_cis`: specialized for mobile phone numbers in CIS countries (Commonwealth of Independent States). Supported phone numbers should starting from country code [`"7"`, `"8"`, `"373"`, `"374"`, `"375"`, `"992"`, `"993"`, `"994"`, `"995"`, `"996"`, `"997"`, `"998"`]. The Russian Federation mobile phone numbers which are started from DEF code `"9XX"` (10 digits) are also supported. Both printed and handwritten text lines are supported, including the ones written in several text lines.
 - `card_number`: card number recognition. Both printed and handwritten text lines are supported, including the ones written in several text lines.
 - `inn`: Taxpayer identification number in the legal system of Russian Federation.
 - `rus_bank_account`: Bank account number in the financial system of Russian Federation.
 - `rcbic`: Bank identification code in the financial system of Russian Federation.
 - `iban`: IBAN number (according to [ISO 13616](https://www.iso.org/standard/41031.html))
 - `vin`: Vehicle Identification Number (17 symbols). Only the printed VINs are supported.
 - `meters`: Reading of consumption data from water meters or energy meters (gas, electric). Both analog and digital meters in any orientation are supported.

By default these types are disabled.

:warning: There are groups of types that are mutually exclusive (several enabled types are allowed if they belong to the same group). Particularly, the groups are the following [[`phone_number`, `phone_number_cis`, `card_number`], [`inn`, `kpp`, `rus_bank_account`, `rcbic`], [`iban`], [`meters`], [`vin`]].

The type of codified text line must be explicitly specified using the corresponding session option:
```c++
settings->SetOption("code_text_line.card_number.enabled", "true");
```

The engine is able to simultaneously recognize several objects, regardless of the enabled types. To specify the maximum number of objects in the result:
```c++
settings->SetOption("code_text_line.maxAllowedObjects", "max_number_of_objects");
```
where `max_number_of_objects` is an integer value. By default the `max_number_of_objects` is set to `3`.

This engine can recognize both printed and handwritten text lines.

:warning: To increase recognition performance a region of interest for text line may be provided. Particularly, the text line should occupy at least one third of the given region of interest in the area.

#### Container recognition
The `container_recog` engine recognizes the identification number of intermodal (shipping) container. 

By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("container_recog.enabled", "true");
```

The recognition result contain the following fields: `owner`, `number`, `control_digit`, `size_type`, `container_number`. The `container_number` is presented only if `owner`, `number` and `control_digit` are validated according to the ISO 6346 validation algorithm.

The engine is able to simultaneously recognize several objects, regardless of the enabled types. To specify the maximum number of objects in the result:
```c++
settings->SetOption("container_recog.maxAllowedObjects", "max_number_of_objects");
```
where `max_number_of_objects` is an integer value. By default the `max_number_of_objects` is set to `1`.


#### Payment details recognition

The `payment_details` engine recognizes payment details presented in the text form required to make a payment in the financial system of Russian Federation. 
By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("payment_details.enabled", "true");
```
To enable recognition of specific type of payment details set the corresponding session option:

```c++
settings->SetOption("payment_details.<type>.enabled", "true");
```
The full list of supported types is the following:
`inn`, `kpp`, `rcbic`, `rus_bank_account`, `personal_account`.

:warning: By default all these types are enabled.

You can specify the maximum number of fields to return for every type of payment details in the recognition session. To achieve that you must set the session option in the following format: 
```c++
settings->SetOption("payment_details.<type>.maxAllowedFields", "number");
```
where `type` is the payment detail type and `number` is the number. By default the `number` is set to `3` for every supported type.

For this engine, there are two supported capture modes: `mobile` and `anywhere`. `mobile` mode mostly addresses handheld camera recognition in videostream, where the target details occupy the most part of the image,  while `anywhere` mode is suitable for images of full page documents.
By default the `mobile` option is enabled.

#### Universal Pay

The **Universal Pay** technology used in Code Engine allows you to recognize objects in a payment document without specifying the type.
Supported objects:
- payment barcode according to the GOST R 56042-2014 standard: QR Code, Aztec сode, Data Matrix;
- bank card;
- phone number;
- bank card number.

The client provides a sequence of images as input, and the session recognizes and puts into the result only those objects for which payment can be made (i.e., other two-dimensional barcodes not in accordance with GOST will be ignored).
One payment object is recognized within one session. After detecting a payment object in a sequence of frames, the session is terminated. One frame is enough for barcodes; for other types of objects, several frames are required.
Examples of the Universal Pay settings:

```c++
settings->SetOption("global.workflow", "universalPay");
settings->SetOption("barcode.enabled", "true");
settings->SetOption("barcode.QR_CODE.enabled", "true");
settings->SetOption("barcode.AZTEC.enabled", "true");
settings->SetOption("barcode.DATA_MATRIX.enabled", "true");
settings->SetOption("barcode.preset", "URL|PAYMENT");
settings->SetOption("barcode.feedMode", "sequence");
settings->SetOption("bank_card.enabled", "true");
settings->SetOption("code_text_line.enabled", "true");
settings->SetOption("code_text_line.phone_number.enabled", "true");
settings->SetOption("code_text_line.card_number.enabled", "true");
```

```java
settings.SetOption("global.workflow", "universalPay");
settings.SetOption("barcode.enabled", "true");
settings.SetOption("barcode.QR_CODE.enabled", "true");
settings.SetOption("barcode.AZTEC.enabled", "true");
settings.SetOption("barcode.DATA_MATRIX.enabled", "true");
settings.SetOption("barcode.preset", "URL|PAYMENT");
settings.SetOption("barcode.feedMode", "sequence");
settings.SetOption("bank_card.enabled", "true");
settings.SetOption("code_text_line.enabled", "true");
settings.SetOption("code_text_line.phone_number.enabled", "true");
settings.SetOption("code_text_line.card_number.enabled", "true");
```
If an exception occurs when you try to use the Universal Pay options, check if they are available or contact us.

#### Licence plate recognition

The `license_plate` engine recognizes vehicle registration plates on the given set of frames.
By default it is disabled. To enable it, set the corresponding session option:
```c++
settings->SetOption("license_plate.enabled", "true");
```
The system supports license plate recognition for multiple countries. Country-specific recognition can be enabled in the settings as needed. By default all countries are disabled. 
```c++
settings->SetOption("license_plate.COUNTRY_CODE.enabled", "true");
```
List of supported countries and their codes in the system is presented in the table.
|                                   Country  |                           Country Code   |
|:-------------------------------------------|:----------------------------------------:|
| `Armenia`                                  | `arm`                                    |
| `Azerbaijan`                               | `aze`                                    |
| `Belarus`                                  | `blr`                                    |
| `Georgia`                                  | `geo`                                    |
| `Germany`                                  | `deu`                                    |
| `France`                                   | `fra`                                    |
| `Kazakhstan`                               | `kaz`                                    |
| `Kyrgyzstan`                               | `kgz`                                    |
| `Moldova`                                  | `mda`                                    |
| `Russian Federation`                       | `rus`                                    |
| `Tajikistan`                               | `tjk`                                    |
| `Uzbekistan`                               | `uzb`                                    |
 

#### Code documentation

All classes and functions have useful Doxygen comments.
Other out-of-code documentation is available at `doc` folder of your delivery.
For complete compilable and runnable sample usage code and build scripts please see `samples` folder.

#### Exceptions

Our C++ API may throw `se::common::BaseException` subclasses when user passes invalid input, makes bad state calls or if something else goes wrong. Most exceptions contain useful human-readable information. Please read `e.what()` message if exception is thrown. Note that `se::common::BaseException` is **not** a subclass of `std::exception`, an Smart Code Engine interface in general do not have any dependency on the STL.

The thrown exceptions are wrapped in general `java.lang.Exception`, so in Java API do catch those.

#### Factory methods and memory ownership

Several Smart Code Engine SDK classes have factory methods which return pointers to heap-allocated objects.  **Caller is responsible for deleting** such objects _(a caller is probably the one who is reading this right now)_.
We recommend using `std::unique_ptr<T>` for simple memory management and avoiding memory leaks.

In Java API for the objects which are no longer needed it is recommended to use `.delete()` method to force the deallocation of the native heap memory.

## Session options

Some configuration bundle options can be overriden in runtime using `CodeEngineSessionSettings` methods. You can obtain all currently set option names and their values using the following procedure:

```cpp
// C++
for (auto it = settings->Begin(); it != settings->End(); ++it) {
    // it.GetKey() returns the option name
    // it.GetValue() returns the option value
}
```

```java
// Java
for (StringsMapIterator it = settings.Begin();
     !it.Equals(settings.OptionsEnd());
     it.Advance()) {
    // it.GetKey() returns the option name
    // it.GetValue() returns the option value
}
```

You can change option values using the `SetOption(...)` method:

```cpp
// C++
settings->SetOption("barcode.enabled", "true");
settings->SetOption("barcode.COMMON.enabled", "true");
```

```java
// Java
settings.SetOption("barcode.enabled", "true");
settings.SetOption("barcode.COMMON.enabled", "true"); 
```

Option values are always represented as strings, so if you want to pass an integer or boolean it should be converted to string first.

#### Global options
|                     Option name |                         Value type |                                           Default | Description                                                                                                                                                                         |
|--------------------------------:|-------------------------------------:|----------------------------------------------------:|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `global.enableMultiThreading`   | `"true"` or `"false"`                | true                                                | Enables parallel execution of internal algorithms                          |
| `global.rgbPixelFormat`         | String of characters R, G, B, and A  | RGB for 3-channel images, BGRA for 4-channel images | Sequence of color channels for session.ProcessSnapshot() method image interpretation |
| `global.sessionTimeout`         | Double value                         | `0.0` for server bundles, `5.0` for mobile bundles  | Session timeout in seconds                          |
| `global.allowSpawnSessionWithoutEngines`| `"true"` or `"false"` | false | Allows to spawn a session without enabling any internal engines                        |


## Processing Feedback

Smart Code Engine SDK supports optional callbacks during document analysis and recognition process before the `Process(...)` method is finished.
It allows the user to be more informed about the underlying recognition process and also helps creating more interactive GUI.

To support callbacks you need to subclasses `CodeEngineWorkflowFeedback` and `CodeEngineVisualizationFeedback` classes and implement desirable callback methods:

```cpp
// C++
class MyWorkflowFeedback : public se::code::CodeEngineWorkflowFeedback {
public:
  virtual ~OptionalWorkflowFeedBack() override = default;

public:
  virtual void ResultReceived(const se::code::CodeEngineResult& result) override { }
  virtual void SessionEnded() override { }
};

class MyVisualizationFeedback : public se::code::CodeEngineVisualizationFeedback {
public:
  virtual ~OptionalVisualizationFeedBack() override = default;

public:
  virtual void FeedbackReceived(
      const se::code::CodeEngineFeedbackContainer& /*feedback_container*/) override { }
};
```

```java
// Java
class MyWorkflowFeedback extends CodeEngineWorkflowFeedback {
  public void ResultReceived(CodeEngineResult result) { }
  public void SessionEnded() { }
}

class MyVisualizationFeedback extends CodeEngineVisualizationFeedback {
  public void FeedbackReceived(CodeEngineFeedbackContainer feedback_container) { }
}
```

You also need to create an instances of `MyWorkflowFeedback` and `MyVisualizationFeedback` somewhere in the code and pass them when you spawn the session:

```cpp
// C++
MyWorkflowFeedback my_workflow_feedback;
MyVisualizationFeedback my_visualization_feedback;
std::unique_ptr<se::code::CodeEngineSession> session(
    engine->SpawnSession(*settings, signature, &my_workflow_feedback, &my_visualization_feedback));
```

```java
// Java
MyWorkflowFeedback my_workflow_feedback = new MyWorkflowFeedback();
MyVisualizationFeedback my_visualization_feedback = new MyVisualizationFeedback();
CodeEngineSession session = engine.SpawnSession(settings, signature, my_workflow_feedback, my_visualization_feedback);
```

**Important!** Your `CodeEngineWorkflowFeedback` and `CodeEngineVisualizationFeedback` subclasses instance must not be deleted while `CodeEngineSession` is alive. We recommend to place them in the same scope. For explanation of signatures, [see above](#warning-personalized-signature-warning).

## Java API Specifics

Smart Code Engine SDK has Java API which is automatically generated from C++ interface by SWIG tool.

Java interface is the same as C++ except minor differences, please see the provided Java sample.

There are several drawbacks related to Java memory management that you need to consider.

#### Object deallocation

Even though garbage collection is present and works, it's strongly advised to manually call `obj.delete()` functions for our API objects because they are wrappers to the heap-allocated memory and their heap size is unknown to the garbage collector.

```java
CodeEngine engine = CodeEngine.CreateFromEmbeddedBundle(true); // or any other object

// ...

engine.delete(); // forces and immediately guarantees wrapped C++ object deallocation
```

This is important because from garbage collector's point of view these objects occupy several bytes of Java memory while their actual heap-allocated size may be up to several dozens of megabytes. GC doesn't know that and decides to keep them in memory – several bytes won't hurt, right?

You don't want such objects to remain in your memory when they are no longer needed so call `obj.delete()` manually.

#### Feedback scope

When using optional callbacks by subclassing `CodeEngineWorkflowFeedback` or `CodeEngineVisualizationFeedback` please make sure that its instance have the same scope as `CodeEngineSession`. The reason for this is that our API does not own the pointer to the feedback instance which cause premature garbage collection resulting in crash:

```java
// Java
// BAD: may cause premature garbage collection of the feedback instance
class MyRecognizer {
    private CodeEngine engine;
    private CodeEngineSession session;

    private void InitializeSmartCodeEngine() {
        // ...
        session = engine.SpawnSession(settings, signature, new MyWorkflowFeedback(), new MyVisualizationFeedback());
        // feedback objects might be garbage collected there because session doesn't own it
    }
}
```

```java
// Java
// GOOD: reporter have at least the scope of recognition session
class MyRecognizer {
    private CodeEngine engine;
    private CodeEngineSession session;
    private MyWorkflowFeedback workflow_feedback; //
    private MyVisualizationFeedback visualization_feedback; // feedbacks has session's scope

    private void InitializeSmartCodeEngine() {
        // ...
        workflow_feedback = new MyWorkflowFeedback();
        visualization_feedback = new MyVisualizationFeedback();
        session = engine.SpawnSession(settings, signature, workflow_feedback, visualization_feedback);
    }
}
```

For explanation of signatures, [see above](#warning-personalized-signature-warning).
