#' compile_xlsform function file.
#'
#' @param filename The name of the external csv file with names and PIDS.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @param layer_list A labeled list of network questions to construct.
#' @return An XLSForm formated "xlxs" file is saved to the working directory This file can be uploaded to KoboCollect. 
#' @export

compile_xlsform = function(filename = "names.csv", type = "jpg", layer_list){
  
  # Extract layer names and questions from the list
  layer_vec = layer_question = rep(NA, length(layer_list))
  for(i in 1:length(layer_list)){
    layer_vec[i] = names(layer_list)[i]
    layer_question[i] = layer_list[[i]]
  }
  
  # Primary object, focal information
  obj1 = focal_info(filename, type)
  
  # List to store the output of the net_layer function
  vec = vector(mode = "list", length = length(layer_list))
  
  # Loop
  for(i in 1:length(layer_list)){
    vec[[i]] = net_layer(filename = filename, 
                          layer = layer_vec[i], 
                          layer_question = layer_question[i], 
                          type = type)
  }
  
  # Bind all the elements of the vector: this is an object containing all the network questions
  obj2 = do.call(rbind, vec)
  
  # Bind together with the focal info group to create the main sheet of the xlsform
  form = rbind(obj1, obj2)
  
  # Turn it into dataframe for xlsx export
  survey = data.frame(form)
  colnames(survey) = colnames(form)
  
  # Create the choices sheet of the xlsform
  choices = data.frame(rbind(rep(NA, 3)))
  colnames(choices) = c("list_name", "name", "label")
  
  # Create list to turn into xlsform export
  xlsform_list = list(survey = survey,
                       choices = choices)
  
  # Export xlsform to working directory
  writexl::write_xlsx(xlsform_list, "network_collect.xlsx")
}

