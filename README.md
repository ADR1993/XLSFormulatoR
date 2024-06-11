XLSFormulatoR
========
<img align="right" src="https://github.com/ADR1993/XLSFormulatoR/blob/main/logo.png" alt="logo" width="270"> 

XLSFormulatoR is an R package that facilitates the design of XLSForm surveys to collect social network data with the photo-roster-based name-generator workflow described by Dalla Ragione et al. (2024). It also provides a function that loads the data export from the KoboToolbox platform and turns it into a dataframe in edgelist format in R.

-----

Setup
------
Install by running on R:
```{r}
library(devtools)
install_github('ADR1993/XLSFormulatoR')
library(XLSFormulatoR)
```

Next, load the package and set a path to where a directory can be created. The setup_folders function will create a directory where some user-editable R and Stan code will be stored.
```{r}
questions = list(
 "friendship" = "Please list the names of your closest friends.",
 "giving" = "Please list the names of people who you have given money to in the last 30 days.",
 "receiving" = "Please list the names of people who have given money to you in the last 30 days.")

compile_xlsform(questions)
```

Once this directory is created, the user can add any new strategy files into the folder "PrisonersDilema/StrategiesR". These new files can then be added to the namespace by running:
```{r}
dat = read_excel(file.choose())
d = kobo_to_edgelist(dat, save=NULL)
```


