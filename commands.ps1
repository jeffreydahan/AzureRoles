# https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-settings-v2-cmdlets

# Prepare PowerShell
install-module azuread
import-module azuread
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

# Authenticate
Connect-AzureAD -TenantId
Connect-AzAccount

# Variables
$TenantID = ""                           # Enter Your Data
$SubscriptionId = ""                     # Enter Your Data
$ResourceGroupName = "test"              # Enter Your Data
$ResourceName = "testvnet"               # Enter Your Data
$GroupName = "test group"                # Enter Your Data

# Get Resource IDs
$ResourceGroupId = (Get-AzResourceGroup -Name $ResourceGroupName).ResourceId
$ResourceId = (Get-AzResource -ResourceGroupName $ResourceGroupName -Name $ResourceName).ResourceId
$SubscriptionId = "/subscriptions/"+$SubscriptionId

# Enter Role Names to Scope Mapping      # Enter Your Data
$rolemap = @(
	@{RoleName = 'Spatial Anchors Account Reader'; Scope = $SubscriptionId},
	@{RoleName = 'Spatial Anchors Account Owner'; Scope = $ResourceGroupId},
	@{RoleName = 'Spatial Anchors Account Contributor'; Scope = $ResourceId}
)

# Get Users from GroupName
$GroupID = (Get-AzureADGroup -filter "displayName eq '$GroupName'").ObjectId
$UserObjectIDs = (Get-AzureADGroupMember -ObjectId $GroupID).ObjectId

# Iterate through the role map and assign roles to scopes and users
for ($u = 0; $u -lt $UserObjectIDs.length; $u++){
	for ($r = 0; $r -lt $rolemap.length; $r++){
		# Assign Role
		Write-Host "Role Assignment -> UserObjectID: " $UserObjectIDs[$u] "; Role: " $rolemap[$r].RoleName "; Scope: " $rolemap[$r].Scope
		New-AzRoleAssignment -ObjectId $UserObjectIDs[$u] -RoleDefinitionName $rolemap[$r].RoleName -Scope $rolemap[$r].Scope 
	}
}
