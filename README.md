XLSFormulatoR
========
<img align="right" src="https://github.com/ADR1993/XLSFormulatoR/blob/main/logo.png" alt="logo" width="250"> 

XLSFormulatoR is an R package that facilitates the design of XLSForm-based surveys aimed at collecting social network data.
Following the photo-roster-based, name-generator workflow on KoboToolbox described in [Dalla Ragione et al. (2024)](https://osf.io/preprints/socarxiv/gna3d), XLSFormulatoR outputs XLSForms containing repeat groups to accomodate any arbitrary number of types of networks that the end-user is interested in collecting. 

We also provide a full pipe-line, allowing users to define their question lists in R, build an XLS form internally, then push that survey to KoboToolbox, upload any media, and then deploy the survey:  all via Kobo's API without leaving R. We also provide functions that load the data export from the KoboToolbox platform and turn it into a dataframe in edgelist format in R.

-----

Install
------
Install by running in R:
```{r}
library(devtools)
install_github('ADR1993/XLSFormulatoR')
library(XLSFormulatoR)
```

Setup
------
Setup the pipeline by logging in to Kobo and initializing a directory for the survey media:
```{r}
############################################################# Initial setup
# Load package
 library(XLSFormulatoR)

# Setup credentials
 server_id = "kf.kobotoolbox.org"                             # Your Kobo server
 username = "user_name"                                       # Your Kobo login name 
 api_token = kobo_login(server_id, username, password=NULL)   # Prompt for password, so as not to store it in script

# Data stuff
 main_path = "C:/Users/CJJacksonIII/Desktop/KoboNetworkSurvey/"   # Set path to where workspace will be created
 dir.create(main_path)                                            # Create a new folder
 setwd(main_path)                                                 #

 dir.create("Photos")                                             # Create subfolder for images

 # Copy example photos and name/id list from package source into workspace
 file.copy(list.files(paste0(path.package("XLSFormulatoR"),"/","photos"), full.names=TRUE), paste0(main_path,"Photos"), overwrite = TRUE)
 file.copy(paste0(path.package("XLSFormulatoR"),"/","names.csv"), paste0(main_path), overwrite = TRUE)

 # For your own surveys, you will need to move your own photos and create your own names.csv file based on the template

 # Prepare some extra path and file info
 media_folder = paste0(main_path,"Photos")
 media_files = list.files(path = media_folder)
 roster_file = "names.csv" 
 xlsform_file = "NetCollect_English.xlsx"
```

Build the Survey
------
Design your network survey, with introduction, network questions, follow-up question on out-of-sample alters, and additional post-network survey questions:
```{r}
########################################################################### Now build survey
# Introduction and consent, plus any pre-network survey questions
intro_list = list( 
 "intro" = extra_question(prompt = "Hello again. We are continuing the research study that we conducted last year.", 
                          type = "note", 
                          options = NULL),

 "consent" = extra_question(prompt = "As before, participation in this study is entirely voluntary, and you can choose whether or not to participate. 
                                      We may include the data we collect in scientific publications, but the data will be anonymous.", 
                            type = "select_one", 
                            options = c("I understand the details and want to participate", "I do not want to participate")),

 "excitement" = extra_question(prompt = "How much do you like doing surveys?", 
                                 type = "likert", 
                                 options = c("Not at all", "A little bit", "A lot", "They are the best!")),

 "net_start" = extra_question(prompt = "Now we will begin with questions about social relationships.", 
                              type = "note", 
                              options = NULL)
)

# Network Questions
questions = list(
 "friends" = "Who are your closest friends?",
 "poorest" = "Who are the poorest people in the community?",
 "richest" = "Who are the richest people in the community?",
 "outside" = "Who are people outside the community that help you?"
)

# Follow up questions for out-of-roster alters
follow_up_list = list(
 "age" = alter_question(prompt = "How old is this person?", 
                        type = "decimal", 
                        options = NULL), 

 "sex" = alter_question(prompt = "What is the sex of this person?", 
                        type = "select_one", 
                        options = c("Female","Male")),

 "occupation" = alter_question(prompt = "What is the occupation of this person?", 
                             type = "text", 
                             options = NULL)
 )

# Additonal questions for focal to do after network interview
add_on_list = list( 
 "food_start" = extra_question(prompt = "Now we have some questions about your familys food security.", 
                               type = "note", 
                               options = NULL), 

 "food_none" = extra_question(prompt = "In the past month, how often have your family members had no food of your own to eat?", 
                              type = "likert", 
                              options = c("Never", "Rarely", "Sometimes", "Often")),

 "uncertainty" = extra_question(prompt = "In your town, how correlated are economic challenges?", 
                                type = "select_one", 
                                options = c("In my town, we all experience the same ups and the same downs at the same time.",
                                            "In my town, at any given time, some people can be quite well-off while others are struggling."))
)

# Build survey
compile_xlsform(layer_list = questions, filename_roster = roster_file, filename_xlsform = xlsform_file,
                type = "jpeg", photo_confirm = "all", 
                follow_up_questions = follow_up_list, follow_up_type = "external", 
                extra_questions_before = intro_list,
                extra_questions_after = add_on_list)
```

Deploy to KoboToolbox
------
Push your survey to KoboToolbox, upload your media files (i.e., facial photos), and deploy the form via API calls:
```{r}
# Upload the XLSForm to create a project
project = upload_xlsform(server_id, paste0(main_path, xlsform_file), api_token, form_name = xlsform_file)

# Build urls on new project
asset_id = project$uid
url_list = make_kobo_urls(server_id, asset_id)

# Now upload the names roster
upload_media(url_list$media_url, paste0(main_path, roster_file), api_token)

# Then upload all of the images
upload_all(url_list$media_url, media_folder, media_files, api_token, wait_time = 0.1, overwrite = FALSE)

# Redeploy to bring live
deploy_form(url_list$api_url, asset_id, api_token, redeploy=TRUE)

# Now download form and collect data on the KoboToolbox App
```

Download your data
------
 Finally, build your data export and download you data via API calls, then use XLSFormulatoR to build clean edgelists from the Kobo multi-sheet XLSX data:
```{r}
# Now download form and collect data on the KoboToolbox App

# Create an export to check data as collected
export_loc = create_export(url_list$export_url, api_token)
data_file = download_export(export_loc, main_path, api_token, overwrite = TRUE)

# Convert to edgelist and explore
d = kobo_to_edgelist(data_file, questions, save = FALSE)
```

Learn more
------
For more details, see our paper in Field Methods. For stand-alone R scripts of the above, click [here (English)](https://github.com/ADR1993/XLSFormulatoR/blob/main/inst/BasicExample.R) or [here (Spanish)](https://github.com/ADR1993/XLSFormulatoR/blob/main/inst/SpanishExample.R). 
