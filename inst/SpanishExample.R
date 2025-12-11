########################################################################### Inital setup
# Load package
 library(XLSFormulatoR)

# Setup credentials
 server_id = "kf.kobotoolbox.org"                                        # Your Kobo server
 username = "Curtis_JacksonIII"                                          # Your Kobo login name 
 api_token = kobo_login(server_id, username, password=NULL)              # Prompt for password, so as not to store it in script

# Data stuff
 main_path = "C:/Users/CurtisJamesJacksonIII/Desktop/KoboNetworkSurveySpanish/"   # Set path to where workspace will be created
 dir.create(main_path)                                                            # Create a new folder
 setwd(main_path)                                                                 #

 dir.create("Photos")                                                 # Create subfolder for images

 # Copy example photos and name/id list from package source into workspace
 file.copy(list.files(paste0(path.package("XLSFormulatoR"),"/","photos"), full.names=TRUE), paste0(main_path,"Photos"), overwrite = TRUE)
 file.copy(paste0(path.package("XLSFormulatoR"),"/","names.csv"), paste0(main_path), overwrite = TRUE)

 # For your own surveys, you will need to move your own photos and create your own names.csv file

 # Prepare some extra path and file info
 media_folder = paste0(main_path,"Photos")
 media_files = list.files(path = media_folder)
 roster_file = "names.csv" 
 xlsform_file = "NetCollect_Spanish.xlsx"

########################################################################### Now build survey
# Introduction and consent, plus any pre-network survey questions
intro_list = list( 
 "intro" = extra_question(prompt = "Hola de nuevo. Estamos continuando el estudio de investigacion que hicimos el anyo pasado.", 
                          type = "note", 
                          options = NULL),

 "consent" = extra_question(prompt = "Como antes, la participacion en este estudio es totalmente voluntaria, y tu puedes elegir participar o no. 
                                      Es posible que incluyamos los datos que recopilemos en publicaciones cientificas, pero los datos seran anonimos.", 
                            type = "select_one", 
                            options = c("Entiendo los detalles y quiero participar", "No quiero participar")),

 "excitement" = extra_question(prompt = "Te gusta hacer encuestas?", 
                               type = "likert", 
                               options = c("No", "Un poco", "Mucho", "Es lo mejor!")),

 "net_start" = extra_question(prompt = "Ahora empezamos con preguntas sobre las relaciones sociales.", 
                              type = "note", 
                              options = NULL)
)

# Network Questions
questions = list(
"friends" = "¿Quiénes son tus amigos más cercanos?",
"poorest" = "¿Quiénes son las personas más pobres de la comunidad?",
"richest" = "¿Quiénes son las personas más ricas de la comunidad?",
"outside" = "¿Quiénes son las personas fuera de la comunidad que te ayudan?"
)

# Follow up questions for out-of-roster alters
follow_up_list = list(
 "age" = alter_question(prompt = "¿Qué edad tiene esta persona?", 
                        type = "decimal", 
                        options = NULL), 

 "sex" = alter_question(prompt = "¿Cuál es el sexo de esta persona?", 
                        type = "select_one", 
                        options = c("Femenino", "Masculino")),

 "occupation" = alter_question(prompt = "¿Cuál es la ocupación de esta persona?", 
                             type = "text", 
                             options = NULL)
 )

# Additonal questions for focal to do after network interview
add_on_list = list( 
  "food_start" = extra_question(
    prompt = "Ahora tenemos algunas preguntas sobre la seguridad alimentaria de tu familia.",
    type = "note",
    options = NULL), 

  "food_none" = extra_question(
    prompt = "En el último mes, ¿con qué frecuencia los miembros de tu familia no han tenido alimentos propios para comer?",
    type = "likert",
    options = c("Nunca", "Raramente", "A veces", "A menudo")),

  "uncertainty" = extra_question(
    prompt = "En tu pueblo, ¿qué tan correlacionados están los desafíos económicos?",
    type = "select_one",
    options = c(
      "En mi pueblo, todos experimentamos los mismos altibajos al mismo tiempo.",
      "En mi pueblo, en cualquier momento, algunas personas pueden estar bastante bien mientras otras están pasando dificultades."))
)

# Prepare Spanish headers
headers = internationalize_headers(name_focal="Seleccionar el nombre de la persona entrevistada", 
                                   confirm_identity = "Confirmar la identidad de la persona entrevistada", 
                                   name_alter = "Escribir el nombre de la persona", 
                                   list_individuals = "Enumerar personas", 
                                   another_person = "otra persona", 
                                   follow_up = "Ya registraste informacion adicional sobre esta persona?",
                                   follow_yes = "Si",
                                   follow_no = "No",
                                   follow_intro = "Ahora tenemos algunas preguntas adicionales sobre las personas que no aparecen en la lista.")

# Finally, compile the XLSX form
compile_xlsform(layer_list = questions, filename_roster = roster_file, filename_xlsform = xlsform_file,
                type = "jpeg", photo_confirm = "all", 
                follow_up_questions = follow_up_list, follow_up_type = "external", 
                extra_questions_before = intro_list,
                extra_questions_after = add_on_list,
                headers = headers)

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

# Create an export to check data as collected
export_loc = create_export(url_list$export_url, api_token)
data_file = download_export(export_loc, main_path, api_token, overwrite = TRUE)

# Convert to edgelist and explore
d = kobo_to_edgelist(data_file, questions, save = FALSE)

