#' layer_to_edgelist function file.
#'
#' @param d A repeat group KoboCollect output.
#' @param layer The name of the network layer
#' @return A list containing a network edgelist and a hash list for out of roster individuals for the given network layer. 
#' @export

layer_to_edgelist = function(d, layer){
    d = d %>% filter(!is.na(.data[[paste0(layer, "_name")]]))                          # Fix the small-bug coming from an NA row if the users goes back in Kobo

    if(sum(is.na(d[, which(colnames(d) == paste0(layer, "_name"))][[1]])) != nrow(d)){ # WTF does this do?
        d$alter = rep(NA, nrow(d))
        d$focal = rep(NA, nrow(d))
        d$layer = rep(NA, nrow(d))

        for (i in 1:nrow(d)){                                                          # Simplify the branching logic
            if (d[[paste0(layer, "_name")]][i] != "out_of_roster") {
                d$focal[i] = d[[paste0(layer, "_id_display")]][i]
                d$layer[i] = d[[paste0("network_layer_", layer)]][i]
                d$alter[i] = d[[paste0(layer, "_name")]][i]
            }
            else {
                d$focal[i] = d[[paste0(layer, "_id_display_out")]][i]
                d$layer[i] = d[[paste0("network_layer_", layer, "_out")]][i]
                d$alter[i] = d[[paste0(layer, "_hash")]][i]
            }
        }
        edgelist = d[, c("focal", "alter", "layer")]
    }
    else {
        edgelist = data.frame(focal = character(), alter = character(), 
            layer = character())
    }
    return(edgelist)
}



