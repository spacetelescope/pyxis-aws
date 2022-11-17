import boto3
from botocore.config import Config
import os
from argparse import ArgumentParser

retry_config = Config(retries={"max_attempts": 5})
client = boto3.client("s3", config=retry_config)

def s3_upload(keys, bucket_name="uvisqepixel", prefix="preptest"):
    err = None 
    for key in keys:
        obj = f"{prefix}/{key}"
        print(f"uploading to s3:{bucket_name}")
        try:
            with open(f"{key}", "rb") as f:
                client.upload_fileobj(f, bucket_name, obj)
                print(f"Uploaded: {obj}")
        except Exception as e:
            err = e
            continue
    if err is not None:
        print(err)


def s3_download(keys, bucket_name="stpubdata", prefix=None):
    err = None 
    for key in keys: 
        if prefix is None:
            prefix = f"hst/public/{key[:4]}/{key.split('_')[0]}"
        obj = f"{prefix}/{key}"
        print(f"downloading from s3: {bucket_name} : {obj}")
        try:
            with open(f"{key}", "wb") as f:
                client.download_fileobj(bucket_name, obj, f)
        except Exception as e:
            err = e
            continue
    if err is not None:
        print(err)
    return keys


def get_dataset_uri(rootname):
    prop = rootname[:4]
    data_uri = f'hst/public/{prop}/{rootname}/{rootname}_flc.fits'
    return data_uri


def main(rootname, bucket_src, bucket_dest, pfx):
    data_uri = get_dataset_uri(rootname)
    fname = data_uri.split('/')[-1]
    src_pfx = '/'.join(data_uri.split('/')[:-1])
    files = s3_download([fname], bucket_name=bucket_src, prefix=src_pfx)
    s3_upload(files, bucket_name=bucket_dest, prefix=pfx)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--ipst", "-i", default="ien406d3q")
    args = parser.parse_args()
    # rootname = args.ipst #'ien406d3q'
    bucket_src = os.environ.get("BUCKET_SRC", "stpubdata")
    bucket_dest = os.environ.get("BUCKET_DEST", "uvisqepixel")
    prefix = os.environ.get("PREFIX", "preptest")
    main(args.ipst, bucket_src, bucket_dest, prefix)

