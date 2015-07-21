#!/usr/bin/env bash
# Use Rail-RNA v0.1.8a
# Set input/output bucket here -- must be on S3 and consistent with that in prep_scaling_experiments.sh!
BUCKET=s3://rail-eu-west-1
# Get current working directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Submit 28 at 10, 20, and 40 cores. Submit 28 on 40 cores 3 times.
#rail-rna align elastic -i $BUCKET/28geuvadispreprocessed -a hg19 -o $BUCKET/geuvadis28out.10cores -c 10 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_28_with_112_sample_labels.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.15 --core-instance-bid-price 0.15
#rail-rna align elastic -i $BUCKET/28geuvadispreprocessed -a hg19 -o $BUCKET/geuvadis28out.20cores -c 20 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_28_with_112_sample_labels.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.15 --core-instance-bid-price 0.15
#rail-rna align elastic -i $BUCKET/28preprocessed -a hg19 -o $BUCKET/geuvad28out.40cores -c 40 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_28_with_112_sample_labels.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.13 --core-instance-bid-price 0.13
#rail-rna align elastic -i $BUCKET/28geuvadispreprocessed -a hg19 -o $BUCKET/geuvadis28out2.40cores -c 40 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_28_with_112_sample_labels.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.15 --core-instance-bid-price 0.15
rail-rna align elastic -i $BUCKET/28geuvadispreprocessed -a hg19 -o $BUCKET/geuvadis28out3.40cores -c 40 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_28_with_112_sample_labels.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.15 --core-instance-bid-price 0.15

# Submit 56 and 112 at 40 cores
rail-rna align elastic -i $BUCKET/56geuvadispreprocessed -a hg19 -o $BUCKET/geuvadis56out.40cores -c 40 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_56_with_112_sample_labels.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.15 --core-instance-bid-price 0.15
rail-rna align elastic -i $BUCKET/112geuvadispreprocessed -a hg19 -o $BUCKET/geuvadis112out.40cores -c 40 --master-instance-type c3.2xlarge --core-instance-type c3.2xlarge -m ${DIR}/GEUVADIS_112.manifest --ec2-key-name raileuw1 --region eu-west-1 --master-instance-bid-price 0.15 --core-instance-bid-price 0.15
