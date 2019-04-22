# Custom Data Formats Example

This repo shows how to create a custom Data format.



## Steps

In order to create a Custom Data Format we need to create a Module (i.e ./src/main/resources/org/mule/weave/simplefixedwidth/FixedWidth.dwl) where the logic for reading and writing is going to be defined. 


### Define The extension 

In order to do this define a variable with type DataFormat 

```weave
@DataFormatExtension
var ndjson: DataFormat<SchemaUrlSettings, SchemaUrlSettings & EncodingSettings> = {
  //All the mime types accepted by this DataFormat
  acceptedMimeTypes: ["application/x-fw", "application/x-fixed-width"],  
  //Reference to the function that is going to be used for transforming the Binary value into the properer DataWeave value
  reader: readFixedWidth,
  //Reference to the function that will transform the DataWeave value into a Binary data
  writer: writeFixedWidth
}
``` 

Within this value define the properties of 

* `acceptedMimeTypes` : The defines the mimeTypes that are going to be handled by this DataFormat
* `reader`: References to the reader function
* `writer`: Reference to the writer function 


### Write reader function

The read function will receive 3 parameters.

* The first one the content of the Binary to be read and transform to a Value.
* The second one the encoding to be used to read this content.
* The third one is the configuration `settings`. 
The type of this is defined by the DataFormat implementer and is going to be used to hint the user on what settings are valid. 

```weave
    fun readFixedWidth(content: Binary, charset: String, settings: SchemaUrlSettings): Any = ???
```

Inside this function the user needs to write the logic to parse this content.

### Write writer function

The write function will receive two parameters.

* The first one is `theValue` to write and transform it into the Binary 
* The second one is the `settings`
The type of this is defined by the DataFormat implementer and is going to be used to hint the user on what settings are valid.

```weave
    fun writeFixedWidth(theValue: Any, settings: SchemaUrlSettings & EncodingSettings): Binary = ???
```

Inside this function the user needs to write the logic to write the value.

## Register the Extension
    
  Create a file in src/main/resources/META-INF/dw-extensions.dwl that will contain a reference to the Module so that DataWeave knows where the extensions are.
  
```weave
[
    "org::mule::weave::simplefixedwidth::FixedWidth"
]
```
  
## Deploy and Use

Last just deploy it to maven and reference it from the pom.xml in studio   