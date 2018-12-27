# Custom Data Formats Example

This repo shows how to create a custom Data format.


## Steps

1. Create a Module file. (org::mule::weave::simplefixedwidth::FixedWidth.dwl)
    1. Create an instance of type DataFormat
2. Register the extension in (META-INF::dw-extensions.dwl)
3. Create your tests (org::mule::weave::simplefixedwidth::FixedWidthTest)
4. `mvn clean install`
5. Add dependency on your mule app
