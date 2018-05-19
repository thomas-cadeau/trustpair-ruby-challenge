# Trustpair Ruby back-end challenge

The goal of this challenge is to evaluate the candidates for the position of Ruby back-end developer at [Trustpair](https://ww.trustpair.fr/jobs).

## Exercise
Starting from the provided CSV [data.csv](https://github.com/trustpair/jobs/tree/master/ruby/data.csv) file that contains a list of companies and their SIRET number, query a public API for retrieving information and produce a result file in JSON.

The data source to use is the SIRENE database. It is made available by _OpenDataSoft_ through a public REST API.

### Guideline 
* You must create a git repository and commit as your work progresses
  * One commit repository won't be accepted
  * Once you're done, share us the link to your repo or an archive containing your project, including the git history
* You need to setup and provide a full test suite using RSpec 3
* You can use all the gems and tools you need

### Todo
* Starting from the provided CSV, retrieve corporate information from their SIRET through the API
  * Call the API only for companies whose SIRET format is valid
* Generate a JSON file (see below)
* Display in the terminal the statistics in the expected format (see below)

#### Company parts of the JSON file
The JSON file must include the following information for each company (API fields to use provided):
* The company name `l1_normalisee`
* SIRET `siret`
* APE code `apen700`
* The legal nature `libnj`
* The date of creation `dcren`
* The address (concatenation of `numvoie`,`typvoie`, `libvoie`, `codpos` and `libcom`)

#### Statistical part of the JSON file
It must also contain a statistical part, presenting the following information:
* Number of valid SIRETs
* Number of invalid SIRETs
* Number of companies created before 1950
* Number of companies created between 1950 and 1975
* Number of companies created between 1976 and 1995
* Number of companies created before 1995 and 2005
* Number of companies created after 2005

### Expected result
* The application must be run from a terminal without any error
* An `output.json` file must be generated with the right content
* The console should display the following result with the correct values:
```
Data processing complete
* Number of valid SIRETs: [XX]
* Number of invalid SIRETs: [XX]
* Number of companies created before 1950: [XX]
* Number of companies created between 1950 and 1975: [XX]
* Number of companies created between 1976 and 1995: [XX]
* Number of companies created before 1995 and 2005: [XX]
* Number of companies created after 2005: [XX]
```

### Bonus
* Support dynamic parameterization of API fields to export to JSON file
* Caching API data
* Store JSON result somewhere other than locally in a file
* Serve the JSON result through a REST API

## Our expectations
* The solution must be designed so that it can support new needs, eg. change the format of files, add new stats, use another API, etc.
* Performance is important and we will look at how you have managed to optimize it. Input data could be 40 lines like 400,000
* There are many possibilities for code optimization and performance improvements so do your best
* Clean and robust code

*You will present us your work and should justify your choices*

## Resources
* SIRET API documentation: [OpenDataSoft - API] (https://data.opendatasoft.com/api/v2/console) (be careful to use version 2)
  * Dataset ID is `sirene@public`
