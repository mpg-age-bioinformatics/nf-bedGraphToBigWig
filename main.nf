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
mkdir -p /workdir/${bw_output}
bedtools sort -i ${sample} > ${sample}.sorted
bedGraphToBigWig ${sample}.sorted ${params.sizes} /workdir/${bw_output}/${sample_name}.bw
rm ${sample}.sorted
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

    sample=Channel.fromPath( ["${params.bdg_folder}/*.bdg"] )
    sample=sample.map{ "$it.name" }
    sample_name=sample.map{ "$it".replace(".bdg","") }
    // sample.view()
    bedgraphtobigwig_pro(sample,sample_name,bw_output)
}
