XLSFormulatoR
========
<img align="right" src="https://github.com/ctross/IPDToolkit/blob/main/logo.png" alt="logo" width="170"> 

XLSFormulatoR is an R package designed to facilitate the simulation and analysis of iterated prisoner's dilema games using Bayesian discrete mixture models.

To address theoretical questions, IPDToolkit provides a Monte Carlo simulation engine that can be used to generate play between arbitrary strategies in the IPD with arbitration and assess expected pay-offs.  To address empirical questions, IPDToolkit provides customizable, Bayesian finite-mixture models that can be used to identify the strategies responsible for generating empirical game-play data. We present a complete workflow using IPDToolkit to teach end-users its functionality.

-----

Setup
------
Install by running on R:
```{r}
 library(devtools)
 #You might need to turn off warning-error-conversion, because the tiniest warning stops installation
 Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = "true")
 install_github('ctross/IPDToolkit')
```

Next, load the package and set a path to where a directory can be created. The setup_folders function will create a directory where some user-editable R and Stan code will be stored.
```{r}
library(IPDToolkit)
path = "C:\\Users\\Mind Is Moving\\Desktop"
setup_folders(path,import_code=TRUE)
```

Once this directory is created, the user can add any new strategy files into the folder "PrisonersDilema/StrategiesR". These new files can then be added to the namespace by running:
```{r}
integrate_new_functions(path)
```


