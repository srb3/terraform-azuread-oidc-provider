#!/bin/bash
# create-scim-app.sh

TEMPLATE_ID="8adf8e6e-67b2-4cf2-a259-e3dc5476c621"
APP_NAME="my-app-scim-$RANDOM"

# Create the application from gallery template
RESPONSE=$(az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/applicationTemplates/$TEMPLATE_ID/instantiate" \
  --headers "Content-Type=application/json" \
  --body "{\"displayName\": \"$APP_NAME\"}")

echo "RESPONSE: ${RESPONSE}"
echo "Waiting for application creation..."
sleep 15

# Get the application details
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
APP_OBJECT_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].id" -o tsv)
SP_ID=$(az ad sp list --display-name "$APP_NAME" --query "[0].id" -o tsv)

echo "Gallery app created!"
echo "Application Client ID: $APP_ID"
echo "Application Object ID: $APP_OBJECT_ID"
echo "Service Principal ID: $SP_ID"
