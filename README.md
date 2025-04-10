XLSFormulatoR
========
<img align="right" src="https://github.com/ADR1993/XLSFormulatoR/blob/main/logo.png" alt="logo" width="250"> 

XLSFormulatoR is an R package that facilitates the design of XLSForm-based surveys aimed at collecting social network data.
Following the photo-roster-based, name-generator workflow on KoboToolbox described in [Dalla Ragione et al. (2024)](https://osf.io/preprints/socarxiv/gna3d), XLSFormulatoR outputs XLSForms containing repeat groups to accomodate any arbitrary number of types of networks that the end-user is interested in collecting. 

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

### Compile an XLSForm network survey

The `compile_xlsform` function takes 5 more arguments, with defaults.
`filename` (default: `names.csv`) is the external CSV file attached to the KoboToolbox project. It contains the names and IDs of individuals who are part of the sample.
`type` (default: `jpg`) is the extension used for the attached photo roster. 
`photo_confirm` (default: `all`) gives the user the option to not include photo confirmation steps, both focal and alter. 
If `photo_confirm` is set to `only_focal`, the photo confirmation step will only apply for the confirmation of the interviewee's identity.
If `photo_confirm` is set to `none`, no photo confirmation step will appear on screen, neither focal nor alter.
The default `all` will include both focal and alter photo confirmation.
`alter_questions` take a list of follow-up questions on the nominated alters, created with the `alter_question` function (described below).
The function exports a complete XLSForm to the current working directory, ready to be deployed on KoboToolbox. 
```{r}
questions = list(
 "friendship" = "Please list the names of your closest friends.",
 "giving" = "Please list the names of people who you have given money to in the last 30 days.",
 "receiving" = "Please list the names of people who have given money to you in the last 30 days.")

compile_xlsform(layer_list = questions, filename = "names.csv",
                type = "jpg", photo_confirm = "all", alter_questions = NULL)
```

### Follow-up questions

XLSFormulatoR also allows users to supply follow-up questions for the nominations by adding a list of follow-up questions to the `compile_xlsform` function. 
This list is generated using the `alter_question` function, as in the following example:
```{r}
alter_questions = list("Age" = alter_question(prompt = "How old is this person?", 
                                     type = "decimal",
                                     options = NULL), 
              "Alter_relation" = alter_question(prompt = "How would you define your relationship with this person?", 
                                                type = "text",
                                                options = NULL),
              "Wealth_class" = alter_question(prompt = "How would you define the social class of this person?",
                                              type = "likert", 
                                              options = c("Upper class", "Middle class", "Lower class")))
```
`alter_question` takes 4 types: `decimal`, `text`, `select_one`, and `likert`. If `select_one` or `likert` are supplied as input types, the user should also supply a vector containing the list of options that the respondent will be shown.

The question list can then be passed on as an argument to the `compile_xlsform` function. 
```{r}
compile_xlsform(layer_list = questions, filename = "names.csv",
                type = "jpg", photo_confirm = "all", alter_questions = alter_questions)
```
An important feature of the XLSFormulatoR name search is that it allows the addition of out-of-roster individuals to the nominations. 
Researchers have to add a slot called "out_of_roster" in the `names.csv`file that is attached to the project. 
This way, there will be an "Out of roster" alter to be selected in the name search, which brings the interviewer to a text field that can be filled with the out of roster nomination.

To reproduce the workflow in [Dalla Ragione et al. (2024)](https://osf.io/preprints/socarxiv/gna3d), download the `photos.zip` and the `names.csv` files in the `assets` folder. 

### Import the data as an edgelist

An additional feature of the package is the `kobo_to_edgelist` function, which imports the XLS file exported from KoboToolbox and turns the social network information into a dataframe with an edgelist structure in R. 
Out of roster individuals are assigned hash codes as personal identifiers, and a dataframe containing the hash codes and out of roster names (as well as layer information) is included in the function output as a default.
As a default, the function outputs a list whose first element is a network edgelist for all the network layers, and whose second element is a hash list for all the out of roster individuals.
If the `return_hash` argument is set to `FALSE`, just the edgelist is returned.
To use this function, you need the path to the data file and the `questions` object used to generate the XLSForm.
The function also gives the possibility of saving the edgelist in the working directory by setting the `save` argument to the chosen filename.
The function assumes that the data export was produced using the XML values and header options from the downloads page in KoboToolbox.
```{r}
path = file.choose()
d = kobo_to_edgelist(path, questions, return_hash = TRUE, save = TRUE)
```




