### Significance analysis
library("openxlsx")
pro_exp_table = read.xlsx("D:/Umich/courses/BIOINF590/1-s2.0-S0092867420301070-mmc2.xlsx", sheet=2)
idx_name_table = readxl::read_excel("D:/Umich/courses/BIOINF590/1-s2.0-S0092867420301070-mmc1.xlsx") %>% 
  filter(Case_excluded == "No") %>%
  select(idx, Proteomics_Participant_ID, Proteomics_Tumor_Normal)

idx_name_table$Proteomics_Tumor_Normal <- ifelse(str_detect(idx_name_table$Proteomics_Tumor_Normal, "normal"), "Normal", "Tumor")
pro_exp_table_trans = dcast(melt(pro_exp_table, id.vars = "idx"), variable ~ idx)
colnames(pro_exp_table_trans)[1] = "idx"

pro_exp_table_trans_new_name = inner_join(pro_exp_table_trans, idx_name_table, by="idx")
pro_exp_table_trans_new_name_gather = gather(pro_exp_table_trans_new_name, "gene", "exp", 2:11000)

pro_exp_table_trans_new_name_gather_na = pro_exp_table_trans_new_name_gather%>%
  group_by(gene, Proteomics_Tumor_Normal) %>%
  dplyr::summarise(n=sum(!is.na(exp)))

used_gene_normal = pro_exp_table_trans_new_name_gather_na %>%
  filter(Proteomics_Tumor_Normal=="Normal" & n>20)
used_gene_tumor = pro_exp_table_trans_new_name_gather_na %>%
  filter(Proteomics_Tumor_Normal=="Tumor" & n>48)
combined_genes = inner_join(used_gene_normal, used_gene_tumor, by="gene")

pro_exp_table_trans_new_name_gather_test_tumor_high = pro_exp_table_trans_new_name_gather %>%
  filter(gene %in% combined_genes$gene) %>%
  group_by(gene) %>%
  dplyr::summarise(p=wilcox.test(exp~Proteomics_Tumor_Normal, paired = F, alternative = c("less"))$p.value) 

pro_exp_table_trans_new_name_gather_test_tumor_low = pro_exp_table_trans_new_name_gather %>%
  filter(gene %in% combined_genes$gene) %>%
  group_by(gene) %>%
  dplyr::summarise(p=wilcox.test(exp~Proteomics_Tumor_Normal, paired = F, alternative = c("greater"))$p.value) 

pro_exp_table_trans_new_name_gather_test_tumor_two_sides = pro_exp_table_trans_new_name_gather %>%
  filter(gene %in% combined_genes$gene) %>%
  group_by(gene) %>%
  dplyr::summarise(p=wilcox.test(exp~Proteomics_Tumor_Normal, paired = F, alternative = c("two.sided"))$p.value) 

d <- density(pro_exp_table_trans_new_name_gather_test_tumor_two_sides$p)
plot(d)


pro_exp_table_trans_new_name_gather_select = pro_exp_table_trans_new_name_gather %>%
  select(gene, idx, exp)

pro_exp_table_trans_new_name_gather_select_spread = spread(pro_exp_table_trans_new_name_gather_select, idx, exp)

output_tumor_high = inner_join(pro_exp_table_trans_new_name_gather_test_tumor_high, pro_exp_table_trans_new_name_gather_select_spread, by="gene")
output_tumor_low = inner_join(pro_exp_table_trans_new_name_gather_test_tumor_low, pro_exp_table_trans_new_name_gather_select_spread, by="gene")
output_tumor_two_sided = inner_join(pro_exp_table_trans_new_name_gather_test_tumor_two_sides, pro_exp_table_trans_new_name_gather_select_spread, by="gene")

write.table(output_tumor_high, "D:/Umich/courses/BIOINF590/sig_data/ucec_proteome_tumor_high_p.txt", quote = F, sep = "\t", row.names = F)
write.table(output_tumor_low, "D:/Umich/courses/BIOINF590/sig_data/ucec_proteome_tumor_low_p.txt", quote = F, sep = "\t", row.names = F)
write.table(output_tumor_two_sided, "D:/Umich/courses/BIOINF590/sig_data/ucec_proteome_tumor_two_side_p.txt", quote = F, sep = "\t", row.names = F)

output_tumor_high_top5 = head(output_tumor_high[order(output_tumor_high$p,decreasing=F),], n = 5)
output_tumor_low_top5 = head(output_tumor_low[order(output_tumor_low$p,decreasing=F),], n = 5)

gene_list = c("ARID1A", "TP53", "CTNNB1", "PTEN", "KRAS")

output_tumor_sig_gene = output_tumor_high %>%
  filter(gene %in% gene_list)


write.table(output_tumor_high_top5, "D:/Umich/courses/BIOINF590/sig_data/ucec_proteome_tumor_high_p_top5.txt", quote = F, sep = "\t", row.names = F)
write.table(output_tumor_low_top5, "D:/Umich/courses/BIOINF590/sig_data/ucec_proteome_tumor_low_p_top5.txt", quote = F, sep = "\t", row.names = F)
write.table(output_tumor_sig_gene, "D:/Umich/courses/BIOINF590/sig_data/ucec_proteome_tumor_5_sig_genes.txt", quote = F, sep = "\t", row.names = F)

output_tumor_high_top5$p = NULL
output_tumor_low_top5$p = NULL

output_tumor_high_top5_trans = dcast(melt(output_tumor_high_top5, id.vars = "gene"), variable ~ gene)
output_tumor_low_top5_trans = dcast(melt(output_tumor_low_top5, id.vars = "gene"), variable ~ gene)
colnames(output_tumor_high_top5_trans)[1] = "idx"
colnames(output_tumor_low_top5_trans)[1] = "idx"

output_tumor_high_top5_trans = inner_join(output_tumor_high_top5_trans, idx_name_table, by="idx")
output_tumor_high_top5_trans$Proteomics_Participant_ID = NULL
output_tumor_low_top5_trans = inner_join(output_tumor_low_top5_trans, idx_name_table, by="idx")
output_tumor_low_top5_trans$Proteomics_Participant_ID = NULL

output_tumor_high_top5_trans_gather = gather(output_tumor_high_top5_trans, "gene", 'exp', 2:6)
output_tumor_low_top5_trans_gather = gather(output_tumor_low_top5_trans, "gene", 'exp', 2:6)


p1 <-  ggplot(output_tumor_low_top5_trans_gather, aes(x=gene, y=exp, fill=Proteomics_Tumor_Normal)) + 
  geom_boxplot()
p1
p2 <- ggplot(output_tumor_high_top5_trans_gather, aes(x=gene, y=exp, fill=Proteomics_Tumor_Normal)) + 
  geom_boxplot()
p2