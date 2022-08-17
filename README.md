# Salesforce lwc reusable datatable

An extensible and reusable skeleton of an LWC-driven project, which can be used for data analysis-related tasks for a distinct Sobject within your Salesforce org.

# Features
<ul>
    <li>Fieldset driven datatable;</li>
    <li>Infinite loading, by default based on Id ascending order;</li>
    <li>Sorting by following fields: Id; unique and not nullable; autonumber; datetime(won't work if data inserted programmatically, because in such case the records would have the same timestamp). Shortly, to support the infinite loading - we must sort by unique fields only;</li>
    <li>Automatically makes it possible to reveal a parent record in a new tab by adding links to a parent text fields;</li>
    <li>SOSL driven search in all searchable field;</li>
    <li>Fieldset driven preview, doesn't support relationship fields;</li>
    <li>Fieldset-driven filters. Currently implemented for picklist and multipicklist field types only. More or less easily extensible, for example - have a look at the already supported ones.</li>
</ul>

# Diagrams
## Apex
![Diagram](/readme-resources/apex.drawio.png "APEX Diagram")

## LWC
![Diagram](/readme-resources/lwc.drawio.png "LWC Diagram")

# Demo

![Demo](/readme-resources/demo.gif)