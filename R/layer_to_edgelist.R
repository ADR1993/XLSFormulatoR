#' layer_to_edgelist function file.
#'
#' @param d A repeat group KoboCollect output.
#' @param layer The name of the network layer
#' @return A list containing a network edgelist and a hash list for out of roster individuals for the given network layer. 
#' @export

layer_to_edgelist = function(d, layer){
  
  #created hash codes
  hash = openssl::sha1(as.vector(d[,which(colnames(d) == paste0(layer, "_by_hand"))][[1]]))
  
  for(i in 1:nrow(d)){
    
    #network layer name
    if(is.na(d[i,which(colnames(d) == paste0("network_layer_", layer))])){
      d[i,which(colnames(d) == paste0("network_layer_", layer))] = d[i,which(colnames(d) == paste0("network_layer_", layer, "_out"))]
    }
    
    #focal ID
    if(is.na(d[i,which(colnames(d) == paste0(layer, "_id_display"))])){
      d[i,which(colnames(d) == paste0(layer, "_id_display"))] = d[i,which(colnames(d) == paste0(layer, "_id_display_out"))]
    }
    
    #alter ID
    if(d[i,which(colnames(d) == paste0(layer, "_name"))] == "out_of_roster"){
      d[i,which(colnames(d) == paste0(layer, "_name"))] = hash[i]
    }
  }
  
  #edgelist creation
  edgelist = d[,which(colnames(d) %in% c(paste0(layer, "_id_display"), paste0(layer, "_name"), paste0("network_layer_", layer)))]
  colnames(edgelist) = c("alter", "layer", "focal")
  edgelist = edgelist[,c("focal", "alter", "layer")]
  
  #hash dataframe creation
  hash_list = data.frame(hash = as.vector(hash), 
                         name = d[,which(colnames(d) == paste0(layer, "_by_hand"))][[1]])
  hash_list = hash_list[complete.cases(hash_list),]
  hash_list$layer = rep(layer, nrow(hash_list))
  
  #join dataframe and hash list in a list
  ls = list(edgelist, hash_list)
  
  return(ls)
}