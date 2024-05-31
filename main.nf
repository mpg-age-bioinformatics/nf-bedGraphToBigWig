#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process get_images {
  stageInMode 'symlink'
  stageOutMode 'move'

  script:
    """

    if [[ "${params.run_type}" == "r2d2" ]] || [[ "${params.run_type}" == "raven" ]] || [[ "${params.run_type}" == "studio" ]]; 
      then
        cd ${params.image_folder}
        if [[ ! -f bedgraphtobigwig-2.10.sif ]] ;
          then
            singularity pull bedgraphtobigwig-2.10.sif docker://index.docker.io/mpgagebioinformatics/bedgraphtobigwig:2.10
        fi
    fi


    if [[ "${params.run_type}" == "local" ]] ; 
      then
        docker pull mpgagebioinformatics/bedgraphtobigwig:2.10
    fi

    """

}

process bedgraphtobigwig_pro {
  stageInMode 'symlink'
  stageOutMode 'move'

  input:
    val sample
    val sample_name
    val bw_output

  when:
      (  ! file("${params.project_folder}/${bw_output}/${sample_name}.bw").exists() )

  script:
    """
cd /bdg_folder/
mkdir -p ${params.project_folder}/${bw_output}
bedtools sort -i ${sample} > ${sample}.sorted
bedGraphToBigWig ${sample}.sorted ${params.sizes} ${params.project_folder}/${bw_output}/${sample_name}.bw
rm ${sample}.sorted
    """
}

process upload_paths {
  stageInMode 'symlink'
  stageOutMode 'move'
  
  input:
    val bw_output

  script:
  """
    rm -rf upload.txt

    cd ${params.project_folder}/${bw_output}
    for f in \$(ls *pileup.bw) ; do echo "bw_output \$(readlink -f \${f})" >>  upload.txt_ ; done 
    uniq upload.txt_ upload.txt 
    rm upload.txt_
  """
}

workflow images {
  main:
    get_images()
}

workflow bedgraphtobigwig_ATACseq {
  main:
    if ( 'bw_output' in params.keySet() ) {
      bw_output="${params.bw_output}"
    } else {
      bw_output="bw_output"
    }

    if ( 'sajr_output' in params.keySet() ) {
        sample = Channel.fromPath("${params.star_out}/*.bed")
        sample=sample.map{ "$it.name" }
        sample_name = sample.map { "$it".replace(".bed", "") }
    } else {
        sample=Channel.fromPath( ["${params.bdg_folder}/*.bdg"] )
        sample=sample.map{ "$it.name" }
        sample_name=sample.map{ "$it".replace(".bdg","") }
    // sample.view()
    }
    bedgraphtobigwig_pro(sample,sample_name,bw_output)

}

workflow upload {
  if ( 'bw_output' in params.keySet() ) {
    bw_output="${params.bw_output}"
  } else {
    bw_output="bw_output"
  }
  upload_paths(bw_output)
}
