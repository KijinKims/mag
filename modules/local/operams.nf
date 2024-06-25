process OPERAMS {
    tag "$meta.id"

    container "docker.io/skkujin/opera-ms:0.9.0"

    input:
    path contigs
    tuple val(meta), path(long_reads), path(short_reads)

    output:
    tuple val(meta), path("OPERAMS-${meta.id}_contigs.fasta"), emit: assembly
    path "OPERAMS-${meta.id}.log"                              , emit: log
    path "OPERAMS-${meta.id}_contigs.fasta.gz"                 , emit: contigs_gz
    path "versions.yml"                                , emit: versions

    script:
    def args = task.ext.args ?: '--no-ref-clustering'
    """
    perl /operams/OPERA-MS.pl \
        $args
        --contigs-file ${contigs}
        --short-read1 ${short_reads[0]} \
        --short-read2 ${short_reads[1]} \
        --long-read ${long_reads} \
        --out-dir operams \
        --num-processors "${task.cpus}"
    
    mv operams/contigs.fasta OPERAMS-${meta.id}_contigs.fasta
    mv operams/spades.log OPERAMS-${meta.id}.log
    gzip -k "OPERAMS-${meta.id}_contigs.fasta"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        perl: \$(perl --version | sed -n '2 p' | sed "s/^.*(v//; s/).*//")
        operams: \$(perl /operams/OPERA-MS.pl | sed -n '2 p' | sed "s/^.*OPERA-MS v//")
    END_VERSIONS
    """
}
