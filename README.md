XLSFormulatoR
========
<img align="right" src="https://github.com/ADR1993/XLSFormulatoR/blob/main/logo.png" alt="logo" width="250"> 

XLSFormulatoR is an R package that facilitates the design of XLSForm-based surveys aimed at collecting social network data.
Following the photo-roster-based, name-generator workflow on KoboToolbox described in Dalla Ragione et al. (2024), XLSFormulatoR outputs XLSForms containing repeat groups to accomodate any arbitrary number of types of networks that the end-user is interested in collecting. 

It also provides a function that loads the data export from the KoboToolbox platform and turns it into a dataframe in edgelist format in R.

-----

Setup
------
Install by running on R:
```{r}
library(devtools)
install_github('ADR1993/XLSFormulatoR')
library(XLSFormulatoR)
```

The XLSFormulatoR workflow is extremely simple: define a list where each element name refers to the type of social network that you want to collect, and add the corresponding question as list element.
The list is then supplied to the `compile_xlsform` function as the `layer_list` argument.

The `compile_xlsform` function takes 3 more arguments, with defaults.
`filename` (default: `names.csv`) is the external CSV file attached to the KoboToolbox project. It contains the names and IDs of individuals who are part of the sample.
`type` (default: `jpg`) is the extension used for the attached photo roster. 
Finally, `photo_confirm` (default: `all`) gives the user the option to not include photo confirmation steps, both focal and alter. 
If `photo_confirm` is set to `only_focal`, the photo confirmation step will only apply for the confirmation of the interviewee's identity.
If `photo_confirm` is set to `none`, no photo confirmation step will appear on screen, neither focal nor alter.
The default `all` will include both focal and alter photo confirmation.
The function exports a complete XLSForm to the current working directory, ready to be deployed on KoboToolbox. 
```{r}
questions = list(
 "friendship" = "Please list the names of your closest friends.",
 "giving" = "Please list the names of people who you have given money to in the last 30 days.",
 "receiving" = "Please list the names of people who have given money to you in the last 30 days.")

compile_xlsform(layer_list = questions, filename = "names.csv",
                type = "jpg", photo_confirm = "all")
```

An additional feature of the package is the `kobo_to_edgelist` function, which imports the XLS file exported from KoboToolbox and turns it into a dataframe with an edgelist structure in R.
```{r}
loc = file.choose()
d = kobo_to_edgelist(loc, save=NULL)
```


