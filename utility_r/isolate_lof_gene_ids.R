# this should ge thte same resutl as this shell one-liner
# head -n 1 ~/Desktop/wes_lof_aggreagted/wes_lof/wes-lof\ lof\ data//eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt | tr "\t" "\n" > eve.UPENN_Freeze_One.L2.M3.lofMatrix_genecols.txt

# except this slice-and-dice eliminates the "Sample": column header

eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt <-
  read_delim(
    "C:/Users/Mark Miller/Desktop/wes_lof_aggreagted/wes_lof/wes-lof lof data/eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt",
    col_names = FALSE,
    delim = "\t"
  )

print(dim(eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt))

print(eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt[1:3, 1:3])

LOF.gene.ids <-
  as.character(eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt[1, 2:ncol(eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt)])
