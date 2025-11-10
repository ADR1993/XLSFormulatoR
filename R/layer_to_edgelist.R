#' layer_to_edgelist function file.
#'
#' @param d A repeat group KoboCollect output.
#' @param layer The name of the network layer
#' @return A list containing a network edgelist and a hash list for out of roster individuals for the given network layer. 
#' @export

layer_to_edgelist = function(d, layer){
  
  #proceed if the dataframe is not empty
  if( sum(is.na(d[,which(colnames(d) == paste0(layer, "_name"))][[1]])) != nrow(d) ){
    
    #create alter column
    d$alter = rep(NA, nrow(d))
    for(i in 1:nrow(d)){
      if(d[[paste0(layer, "_name")]][i] == "out_of_roster"){
        d$alter[i] = d[[paste0(layer, "_hash")]][i]
      } else {
        d$alter[i] = d[[paste0(layer, "_name")]][i]
      }
    }
    
    #create focal column
    d$focal = rep(NA, nrow(d))
    for(i in 1:nrow(d)){
      if(d[[paste0(layer, "_name")]][i] != "out_of_roster"){
        d$focal[i] = d[[paste0(layer, "_id_display")]][i]
      } else {
        d$focal[i] = d[[paste0(layer, "_id_display_out")]][i]
      }
    }
    
    #create layer column
    d$layer = rep(NA, nrow(d))
    for(i in 1:nrow(d)){
      if(d[[paste0(layer, "_name")]][i] != "out_of_roster"){
        d$layer[i] = d[[paste0("network_layer_", layer)]][i]
      } else {
        d$layer[i] = d[[paste0("network_layer_", layer, "_out")]][i]
      }
    }
    
    #create final edgelist
    edgelist = d[,c("focal", "alter", "layer")]
    
  } else {
    
    #create empty edgelist if the original dataframe is empty
    edgelist = data.frame(
      focal = character(),
      alter = character(),
      layer = character()
    )
  }
  
  return(edgelist)
}
