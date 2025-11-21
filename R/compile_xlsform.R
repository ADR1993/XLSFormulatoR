#' compile_xlsform function file.
#'
#' @param layer_list A labeled list of network questions to construct.
#' @param filename_roster The name of the external csv file with names and PIDS.
#' @param filename_xlsform The name of the XLSForm to be created.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @param photo_confirm A value that specifies whether the photo confirmation group needs to be included in the output. 
#' @param follow_up_questions A named list of follow-up questions created using the alter_question() function.
#' @param follow_up_type A string: "all", "external", or "none", which controls which follow-up questions get asked.
#' @param extra_questions A named list of extra questions created using the extra_question() function.
#' @param headers Accessory prompts for internationalization. Must be NULL, or a 2-list of prompts.
#' Options are "all" (for always), "only_focal" if only confirmation of the focal is needed, and "none" to omit all photo confirmation steps for focal and alters.
#' @return An XLSForm formated "xlxs" file is saved to the working directory This file can be uploaded to KoboCollect. 
#' @export

compile_xlsform = function(layer_list, filename_roster = "names.csv", filename_xlsform="network_collect.xlsx", type = "jpg", photo_confirm = "all", 
                           follow_up_questions = NULL, follow_up_type = NULL, extra_questions = NULL, headers = NULL){
  if(is.null(follow_up_type)){
    follow_up_type = "none"
  }

  if(!follow_up_type %in% c("none", "all", "external")){
    stop("Please choose a valid follow-up type: all, external, none.")
  }

  if(is.null(headers)){
    headers = NULL
    headers[[1]] = NULL
    headers[[2]] = NULL
  }

  if(!photo_confirm %in% c("all", "only_focal", "none")){
    stop("photo_confirm must be one of: all, only_focal, none")
  }
  
  # Extract layer names and questions from the list
  layer_vec = layer_question = rep(NA, length(layer_list))
  for(i in 1:length(layer_list)){
    layer_vec[i] = names(layer_list)[i]
    layer_question[i] = layer_list[[i]]
  }
  
  
  # List to store the output of the net_layer function
  vec = vector(mode = "list", length = length(layer_list))
  
  # Loop conditionally based on the photo confirmation argument
  if(photo_confirm == "all"){
    obj1 = focal_info(filename_roster, type, headers = headers[[1]])
    
    for(i in 1:length(layer_list)){
      vec[[i]] = net_layer(filename = filename_roster, 
                           layer = layer_vec[i], 
                           layer_question = layer_question[i], 
                           type = type, 
                           headers = headers[[2]])
    }
  } 
  
  if(photo_confirm == "only_focal"){  
    obj1 = focal_info(filename_roster, type, headers = headers[[1]])
    
    for(i in 1:length(layer_list)){
      vec[[i]] = net_layer(filename = filename_roster, 
                           layer = layer_vec[i], 
                           layer_question = layer_question[i], 
                           type = type, 
                           headers = headers[[2]])[-c(7:12),]
    }
  }
  
  if(photo_confirm == "none"){  
    obj1 = focal_info(filename_roster, type, headers = headers[[1]])[-c(9:13),]
    
    for(i in 1:length(layer_list)){
      vec[[i]] = net_layer(filename = filename_roster, 
                           layer = layer_vec[i], 
                           layer_question = layer_question[i], 
                           type = type,
                           headers = headers[[2]])[-c(7:12),]
    }
  }
  
  # Bind all the elements of the vector: this is an object containing all the network questions
  obj2 = do.call(rbind, vec)
  
  #create the follow-up groups for each layer if the follow_up_questions list is supplied
  if(follow_up_type != "none"){
    
    follow_up_list = vector(mode = "list", length = length(layer_vec))
    
    for(i in 1:length(layer_vec)){
      follow_up_list[[i]] = layer_details(layer_vec = layer_vec[i], follow_up_questions = follow_up_questions, follow_up_type = follow_up_type)
    }
    
    obj3 = do.call(rbind, follow_up_list)
    
    # Bind together with the focal info group to create the main sheet of the xlsform
    form = rbind(obj1, obj2, obj3)
  } 


  if(follow_up_type == "none"){
    form = rbind(obj1, obj2)
  }

  # Turn it into dataframe for xlsx export
  survey = data.frame(form)
  colnames(survey) = colnames(form)
  
  ### Create the choices sheet of the xlsform
  #if there is at least a choice list provided in the follow_up_questions object
  if(is.null(follow_up_questions) == FALSE){
    
    q_choices = sapply(follow_up_questions, function(x) x[[3]])
    
    if(any(!sapply(q_choices, is.null)) == TRUE){ 
      
      #choice labels
      choice_label_vec = Filter(Negate(is.null), q_choices)
      choice_label = unlist(choice_label_vec)
      
      #choice names
      choice_name = gsub("\\s+", "_", trimws(choice_label))
      
      #list_name for choices
      list = vector(mode = "list", length = length(choice_label_vec))
      for(i in 1:length(choice_label_vec)){
        list[[i]] = rep(gsub("\\s+", "_", names(choice_label_vec)[i]), length(choice_label_vec[[i]]))
      }
      choice_list_name = paste0(unlist(list), "_scale")
      
      #choices dataframe
      choices = data.frame(choice_list_name, choice_name, choice_label)
      colnames(choices) = c("list_name", "name", "label")
    }
    
    #if no choice list is supplied in the follow_up_questions object
    if(any(!sapply(q_choices, is.null)) == FALSE){ 
      choices = data.frame(rbind(rep(NA, 3)))
      colnames(choices) = c("list_name", "name", "label")
    }
  } else {
    #empty choice sheet in case follow_up_questions list not supplied
    choices = data.frame(rbind(rep(NA, 3)))
    colnames(choices) = c("list_name", "name", "label")
  }


  #######################

  if(is.null(extra_questions) == FALSE){

    q_names = gsub("\\s+", "_", trimws(names(extra_questions))) #question names to use in pasting
    q_prompts = sapply(extra_questions, function(x) x[[1]]) #question prompts to use in pasting
    q_types = sapply(extra_questions, function(x) x[[2]]) #question types to use in pasting
    q_choices = sapply(extra_questions, function(x) x[[3]]) #choice list for select_one and likert questions

    for(i in 1:length(extra_questions)){
      survey = rbind(survey, extra_q(q_names[i], q_prompts[i], q_types[i], choice_list = q_choices[[i]]))
    }

    extra_choice_label_vec = Filter(Negate(is.null), q_choices)
    extra_choice_label = unlist(extra_choice_label_vec)
    extra_choice_name = gsub("\\s+", "_", trimws(extra_choice_label))
    extra_list = vector(mode = "list", length = length(extra_choice_label_vec))
    for(i in 1:length(extra_choice_label_vec)){
      extra_list[[i]] = rep(gsub("\\s+", "_", names(extra_choice_label_vec)[i]), length(extra_choice_label_vec[[i]]))
      }
    extra_choice_list_name = paste0(unlist(extra_list), "_scale")

    extra_choices = data.frame(extra_choice_list_name, extra_choice_name, extra_choice_label)
    colnames(extra_choices) = colnames(choices)

    choices = rbind(choices, extra_choices)
    choices = choices[complete.cases(choices),]
  }


  # Create list to turn into xlsform export
  xlsform_list = list(survey = survey,
                      choices = choices)
  
  # Export xlsform to working directory
  writexl::write_xlsx(xlsform_list, filename_xlsform)
}