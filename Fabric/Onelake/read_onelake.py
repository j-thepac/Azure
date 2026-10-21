# pip install azure-storage-file-datalake azure-identity
# https://learn.microsoft.com/en-us/fabric/onelake/onelake-access-python






from azure.storage.filedatalake import (
    DataLakeServiceClient,
    DataLakeDirectoryClient,
    FileSystemClient
)
from azure.identity import DefaultAzureCredential
ACCOUNT_NAME = "onelake" # dont chnage
WORKSPACE_NAME = "MySampeWorkspace"
DATA_PATH = "Demo.Lakehouse/Files/tmp/" #right click on Lakehouse file and copy the path




def main():
    #az login
    account_url = f"https://{ACCOUNT_NAME}.dfs.fabric.microsoft.com"
    token_credential = DefaultAzureCredential()
    service_client = DataLakeServiceClient(account_url, credential=token_credential)
    file_system_client = service_client.get_file_system_client(WORKSPACE_NAME)
    paths = file_system_client.get_paths(path=DATA_PATH)

    for path in paths:
        print(path.name + '\n')

if __name__ == "__main__":
    main()