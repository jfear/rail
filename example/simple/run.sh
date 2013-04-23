SCR_DIR=../../src/rnawesome

mkdir -p intermediate
INTERMEDIATE_DIR=intermediate/

# Step 1a: Readletize input reads and use Bowtie to align the readlets 
ALIGN_AGGR="cat"
ALIGN="python $SCR_DIR/align.py"

# Step 1b: Bring together all the readlet alignment intervals for a given read and 
SPLICE_AGGR="cat"
SPLICE="python $SCR_DIR/splice.py"

# Steps 1a and 1b happen together in the same map step in practice

# Step 2: Collapse identical intervals from same sample
MERGE_AGGR1="sort -n -k2,2"
MERGE_AGGR2="sort -s -k1,1"
MERGE="python $SCR_DIR/merge.py"

# Step 3: Walk over genome windows and emit per-sample, per-position
#         coverage tuples
WALK_PRENORM_AGGR1="sort -n -k2,2"
WALK_PRENORM_AGGR2="sort -s -k1,1"
WALK_PRENORM="python $SCR_DIR/walk_prenorm.py"

# Step 4: For all samples, take all coverage tuples for the sample and
#         from them calculate a normalization factor
NORMALIZE_AGGR="sort -k1,1"
NORMALIZE="python $SCR_DIR/normalize.py"

# Step 5: Collect all the norm factors together and write to file
NORMALIZE_POST_AGGR="cat"
NORMALIZE_POST="python $SCR_DIR/normalize_post.py"

# Step 6: Walk over genome windows again (taking output from Step 2)
#         but this time, calculate per-position coverage vectors and
#         fit a linear model to each
WALK_FIT="python $SCR_DIR/walk_fit.py"

# Step 7: Given all the t-statistics, moderate them and emit moderated
#         t-stats
EBAYES_AGGR="cat"
EBAYES="python $SCR_DIR/ebayes.py"

# Step 8: Given all the moderated t-statistics, calculate the HMM
#         parameters to use in the next step
HMM_PARAMS_AGGR="cat"
HMM_PARAMS="python $SCR_DIR/hmm_params.py"

# Step 9: Given sorted bins of moderated t-statistics, and HMM
#         parameters, run the HMM
HMM_AGGR1="sort -n -k2,2"
HMM_AGGR2="sort -s -k1,1"
HMM="python $SCR_DIR/hmm.py"

# Temporary files so we can form a DAG
WALK_IN_TMP=${TMPDIR}walk_in.tsv
HMM_IN_TMP=${TMPDIR}hmm_in.tsv

# Parameters
GENOME_LEN=1000
NTASKS=10
HMM_OVERLAP=30

echo "Temporary file for walk_fit.py input is '$WALK_IN_TMP'"
echo "Temporary file for hmm.py input is '$HMM_IN_TMP'"

cat *.tab \
	| $ALIGN_AGGR | $ALIGN \
		--bowtieArgs '-v 2 -m 1' \
		--bowtieExe $HOME/software/bowtie-0.12.8/bowtie \
		--bowtieIdx=$HOME/software/bowtie-0.12.8/indexes/e_coli \
		--readletLen 20 \
		--readletIval 2 \
		--manifest simple.manifest \
	| $SPLICE_AGGR | $SPLICE \
		--ntasks=$NTASKS \
		--genomeLen=$GENOME_LEN \
		--manifest simple.manifest \
	| $MERGE_AGGR1 | $MERGE_AGGR2 | $MERGE \
	| $WALK_PRENORM_AGGR1 | $WALK_PRENORM_AGGR2 | tee $WALK_IN_TMP | $WALK_PRENORM \
		--manifest simple.manifest \
		--ntasks=$NTASKS \
		--genomeLen=$GENOME_LEN \
	| $NORMALIZE_AGGR | $NORMALIZE \
		--percentile 0.75 \
	| $NORMALIZE_POST_AGGR | $NORMALIZE_POST \
		--manifest simple.manifest > ${INTERMEDIATE_DIR}norm.tsv

cat $WALK_IN_TMP \
	| $WALK_FIT \
		--ntasks=$NTASKS \
		--genomeLen=$GENOME_LEN \
		--seed=777 \
		--normals ${INTERMEDIATE_DIR}norm.tsv \
	| $EBAYES_AGGR | $EBAYES \
		--ntasks=$NTASKS \
		--genomeLen=$GENOME_LEN \
		--hmm-overlap=$HMM_OVERLAP \
	| tee $HMM_IN_TMP | $HMM_PARAMS_AGGR | $HMM_PARAMS \
		--null \
		--out ${INTERMEDIATE_DIR}hmm_params.tsv 

cat $HMM_IN_TMP \
	| $HMM_AGGR1 | $HMM_AGGR2 | $HMM \
		--ntasks=$NTASKS \
		--genomeLen=$GENOME_LEN \
		--params ${INTERMEDIATE_DIR}hmm_params.tsv \
		--hmm-overlap=$HMM_OVERLAP

echo DONE

echo "Normalization file:"
cat ${INTERMEDIATE_DIR}norm.tsv

echo "HMM parameter file:"
cat ${INTERMEDIATE_DIR}hmm_params.tsv
