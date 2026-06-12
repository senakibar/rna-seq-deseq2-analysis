library(DESeq2)
library(airway)
library(ggplot2)
library(ggrepel)

# Load data
data(airway)

# Run DESeq2
dds <- DESeqDataSet(airway, design = ~ cell + dex)
dds <- DESeq(dds)
res <- results(dds, contrast = c("dex", "trt", "untrt"))

# Prepare for plotting
res_df <- as.data.frame(res)
res_df$gene <- rownames(res_df)
res_df <- res_df[!is.na(res_df$padj), ]
res_df$significance <- "Not significant"
res_df$significance[res_df$padj < 0.05 & res_df$log2FoldChange > 1]  <- "Up"
res_df$significance[res_df$padj < 0.05 & res_df$log2FoldChange < -1] <- "Down"
top_genes <- head(res_df[order(res_df$padj), ], 10)

# Volcano plot
ggplot(res_df, aes(x = log2FoldChange, y = -log10(padj), color = significance)) +
  geom_point(alpha = 0.5, size = 1.2) +
  geom_text_repel(data = top_genes, aes(label = gene), size = 3, max.overlaps = 15) +
  scale_color_manual(values = c("Up" = "#E05252", "Down" = "#4A90D9", "Not significant" = "grey70")) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey50") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey50") +
  labs(title = "Dexamethasone treatment vs untreated (airway cells)",
       x = "Log2 Fold Change", y = "-Log10 Adjusted P-value",
       color = "Direction") +
  theme_minimal(base_size = 13)