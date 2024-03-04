# nf-bedGraphToBigWig
Run the workflow:

```
PROFILE=raven
nextflow run nf-bedGraphToBigWig  -params-file  nf-bedGraphToBigWig/params.slurm.json -profile ${PROFILE} -entry images
nextflow run nf-bedGraphToBigWig  -params-file  nf-bedGraphToBigWig/params.slurm.json -profile ${PROFILE} -entry bedgraphtobigwig_ATACseq
```