#' internationalize_headers function file.
#' 
#' This function simply lets users pass non-English texts into the appropriate prompts. Simply translate the defaults and then pass as headers into compile_xlsform().
#'
#' @param name_focal Text to add to relevant field.
#' @param confirm_identity Text to add to relevant field.
#' @param name_alter Text to add to relevant field.
#' @param list_individuals Text to add to relevant field. 
#' @param another_person Text to add to hint field.
#' @param follow_up Text to add to relevant field.
#' @param follow_yes Text to add to relevant field.
#' @param follow_no Text to add to relevant field.
#' @param follow_intro Text to add to relevant field.
#' @return A header list for internationalization of hardcoded prompts.
#' @export

internationalize_headers = function(name_focal="Select name of focal person", 
                                    confirm_identity = "Confirm the identity of the interviewed person", 
                                    name_alter = "Write the name of the person", 
                                    list_individuals = "List individuals", 
                                    another_person = "another person", 
                                    follow_up = "Did you already provide follow-up details about this person?",
                                    follow_yes = "Yes",
                                    follow_no = "No",
                                    follow_intro = "Now we have some follow-up questions about the people not on the roster."){
    headers = NULL
    headers[[1]] = c(name_focal, confirm_identity) 
    headers[[2]] = c(name_alter, list_individuals, another_person) 
    headers[[3]] = c(follow_up, follow_yes, follow_no)
    headers[[4]] = c(follow_intro)

  return(headers)
}

