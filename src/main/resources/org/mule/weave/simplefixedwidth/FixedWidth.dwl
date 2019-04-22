/**
* This module registers a new custom Data Format using the @DataFormatExtension.
*/
%dw 2.0
import * from dw::extension::DataFormat
import fail from dw::Runtime
import dw::core::Binaries

/**
* In order to define the reader and writer configuration properties data weave types needs to be used.
*/
type SchemaUrlSettings = {
    /**
    * The url of the schema for example "classpath://myschema.yaml" or "file:///user/home/myschema.yaml"
    */
    schemaUrl: String
}

type Columns = Array<Column>

type Column = {name: String, width: Number}

type FixedWidthSchema = {columns: Columns}

@TailRec()
fun parseLine(line: String, columns: Columns, index: Number = 0, result: {} = {}): {} = do {
    if(sizeOf(columns) > index) do {
      var newResult = result ++  {
            (columns[index].name) : trim(line[0 to columns[index].width!  -1])
        }
      ---
      parseLine(line[columns[index].width! to -1], columns, index + 1, newResult)
    }
    else
      result
}

@TailRec
fun times(str:String, amount: Number, acc: String = "") =
    if(amount == 0) acc else times(str, amount - 1, acc ++ str)

fun getSchema(settings: SchemaUrlSettings): FixedWidthSchema = do {
  if(settings.schemaUrl?)
    readUrl(settings.schemaUrl, "application/yaml") as FixedWidthSchema
  else
    fail("`schemaUrl` was not specified on input settings.")
}

fun withLength(value: String, length: Number): String =
    if(sizeOf(value) > length)
        value[0 to length]
    else
        value ++ times(" ", length - sizeOf(value))

fun readFixedWidth(content: Binary, charset: String, settings: SchemaUrlSettings):Any = do {
    var schema = getSchema(settings)
    var columns =  schema.columns
    var lines = Binaries::readLinesWith(content, charset)
    ---
    lines map ((line, index) -> parseLine(line, columns))
}


fun writeFixedWidth(content: Any, settings: SchemaUrlSettings & EncodingSettings):Binary = do {
    var columns: Columns = getSchema(settings).columns
    ---
    Binaries::writeLinesWith((content as Array<Object>) map ((line, index) -> do {
        columns reduce ((column, accumulator: String = ""): String ->
                accumulator ++ withLength(line[column.name] as String default "", column.width)
            )
    }), settings.encoding default "UTF-8")
}


/**
* This is the extension where the DataFormat is registered.
* The value needs to implement the DataFormat type from `dw::extension::DataFormat`
*/
@DataFormatExtension
var ndjson: DataFormat<SchemaUrlSettings, SchemaUrlSettings & EncodingSettings> = {
  //All the mime types accepted by this DataFormat
  acceptedMimeTypes: ["application/x-fw", "application/x-fixed-width"],
  fileExtensions: [".fw"],
  //Reference to the function that is going to be used for transforming the Binary value into the properer DataWeave value
  reader: readFixedWidth,
  //Reference to the function that will transform the DataWeave value into a Binary data
  writer: writeFixedWidth
}
