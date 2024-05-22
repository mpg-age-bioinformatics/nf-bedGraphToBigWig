# nf-bedGraphToBigWig

Create the test directory:
```
mkdir -p /tmp/nextflow_atac_local_test/bigwig_test
```

Download the demo data:
```
mkdir -p /tmp/nextflow_atac_local_test/bigwig_test/macs2_output
cd /tmp/nextflow_atac_local_test/bigwig_test/macs2_output
curl -J -O https://datashare.mpcdf.mpg.de/s/S92l2rk46gINdPv/download
```

Download the paramaters file:
```
cd /tmp/nextflow_atac_local_test/bigwig_test/
PARAMS=params.local.json
curl -J -O https://raw.githubusercontent.com/mpg-age-bioinformatics/nf-bedGraphToBigWig/main/${PARAMS}
curl -J -O https://raw.githubusercontent.com/mpg-age-bioinformatics/nf-bedGraphToBigWig/main/mus_musculus.105.genome
```

Get the latest repo:
```
cd /tmp/nextflow_atac_local_test/
git clone https://github.com/mpg-age-bioinformatics/nf-bedGraphToBigWig.git
```

Run the workflow:
```
nextflow run nf-bedGraphToBigWig  -params-file  bigwig_test/${PARAMS} -entry images --user "$(id -u):$(id -g)"
nextflow run nf-bedGraphToBigWig  -params-file  bigwig_test/${PARAMS} -entry bedgraphtobigwig_ATACseq --user "$(id -u):$(id -g)"
```