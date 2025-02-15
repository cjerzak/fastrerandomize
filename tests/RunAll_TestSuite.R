#!/usr/bin/env Rscript
{
  ##########################################
  # code for testing functionalities of fastrerandomize on your hardware
  ##########################################
  tryTests <- try({
    # local install for development team
    # install.packages("~/Documents/fastrerandomize-software/fastrerandomize",repos = NULL, type = "source",force = F)
    
    # remote install latest version of the package
    # devtools::install_github(repo = "cjerzak/fastrerandomize-software/fastrerandomize")

    options(error = NULL)
    t_GenData <- try({
      set.seed(999L, kind = "Wichmann-Hill")
      X <- matrix(rnorm(20*5), 20, 5)
    },T)
    if("try-error" %in% class(t_GenData)){ stop("Failed at t_GenData...") }
    
    for(verbose in c(TRUE, FALSE)){ 
      #for(approx_inv in c(TRUE, FALSE)){
      for(approx_inv in c(TRUE)){ 
    for(type_ in sample(c("exact","monte_carlo"),2)){ for(findFI in sample(c(FALSE, TRUE), 2)){  # random order
      fastrerandomize::print2(sprintf("On type: %s", type_))
      
      t_GetSet <- try({
        RandomizationSet_ <- fastrerandomize::generate_randomizations(
          n_units = 20,
          n_treated = 10,
          X = X,
          randomization_accept_prob = 0.1,
          randomization_type = type_,
          approximate_inv = approx_inv, 
          verbose = verbose, 
          max_draws = 10000L, 
          batch_size = 100L)
      },T)
      if("try-error" %in% class(t_GetSet)){ stop(sprintf("Failed at t_GetSet: %s...",type_)) }
      
      t_RRTest <- try({
        RRTest_ <- fastrerandomize::randomization_test(
          obsW = (W_<-as.integer(RandomizationSet_$randomizations[1,])),
          obsY = rnorm(ncol(RandomizationSet_$randomizations))+2*W_,
          candidate_randomizations = RandomizationSet_$randomizations,
          findFI = findFI, 
          verbose = verbose, 
          X = X)
        if(!is.null(RRTest_$FI)){ 
          print(sprintf("FI: {%s}", paste(round(RRTest_$FI,2),collapse = ", " )))
        }
      },T)
      if("try-error" %in% class(t_RRTest)){ stop(sprintf("Failed at t_RRTest: [%s, %s]...",type_, findFI)) }
    }
    }
    }
    }
  }
  , T)
    
  if('try-error' %in% class(tryTests)){  print( tryTests ); fastrerandomize::print2("At least one test failed... See above.") }
  if(!'try-error' %in% class(tryTests)){ fastrerandomize::print2("All tests succeeded!") }
}

