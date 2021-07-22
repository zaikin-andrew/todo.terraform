sls package
rm -rf dist
mkdir dist
ZIP_NAME="tf_lambda.zip"
cp ./.serverless/todo-terraform.zip ./dist/$ZIP_NAME
S3_BUCKET_NAME="sls-terraform"
S3_SUB_FOLDER=$(openssl rand -hex 12)
TABLE_NAME="Todos-Terraform-demo"
aws s3 rm s3://$S3_BUCKET_NAME --recursive --region=us-east-1 --profile=flo
aws s3api create-bucket --bucket=$S3_BUCKET_NAME --region=us-east-1 --profile=flo
aws s3 cp dist/$ZIP_NAME s3://$S3_BUCKET_NAME/$S3_SUB_FOLDER/$ZIP_NAME --profile=flo
terraform apply -var s3_bucket=$S3_BUCKET_NAME -var zip_name=$ZIP_NAME -var table_name=$TABLE_NAME -var sub_folder=$S3_SUB_FOLDER
