data "aws_ami" "amazon-linux" {
  owners      = ["amazon"]
  most_recent = true


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = var.bastion_instance_type
  key_name      = var.ssh_key_name
  subnet_id     = var.subnet_id_1

  tags = {
    Name = var.bastion_name
  }

  security_groups = ["${aws_security_group.allow_ssh_icmp.id}"]
}

resource "aws_security_group" "allow_ssh_icmp" {
  name        = "allow_ssh_icmp"
  description = "Allow SSH and ALL ICMP IPV4 inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    description = "ALL ICMP IPV4 from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}




resource "aws_ssm_document" "ssm-access" {
  name          = "ec2-ssm-access"
  document_type = "Command"

  content = <<DOC
{
  "schemaVersion": "2.2",
  "description": "Update the Amazon SSM Agent to the latest version or specified version.",
  "parameters": {
    "version": {
      "default": "",
      "description": "(Optional) A specific version of the Amazon SSM Agent to install. If not specified, the agent will be updated to the latest version.",
      "type": "String"
    },
    "allowDowngrade": {
      "default": "false",
      "description": "(Optional) Allow the Amazon SSM Agent service to be downgraded to an earlier version. If set to false, the service can be upgraded to newer versions only (default). If set to true, specify the earlier version.",
      "type": "String",
      "allowedValues": [
        "true",
        "false"
      ]
    }
  },
  "mainSteps": [
    {
      "action": "aws:runPowerShellScript",
      "name": "createUpdateFolder",
      "precondition": {
        "StringEquals": [
          "platformType",
          "Windows"
        ]
      },
      "inputs": {
        "runCommand": [
          "try {",
          "  $sku = (Get-CimInstance -ClassName Win32_OperatingSystem).OperatingSystemSKU",
          "  if ($sku -eq 143 -or $sku -eq 144) {",
          "    Write-Host \"This document is not supported on Windows 2016 Nano Server.\"",
          "    exit 40",
          "  }",
          "  $ssmAgentService = Get-ItemProperty 'HKLM:SYSTEM\\\\CurrentControlSet\\\\Services\\\\AmazonSSMAgent\\\\'",
          "  if ($ssmAgentService -and [System.Version]$ssmAgentService.Version -ge [System.Version]'3.0.1031.0') {",
          "     exit 0",
          "  }",
          "  $DataFolder = \"Application Data\"",
          "  if ( ![string]::IsNullOrEmpty($env:ProgramData) ) {",
          "    $DataFolder = $env:ProgramData",
          "  } elseif ( ![string]::IsNullOrEmpty($env:AllUsersProfile) ) {",
          "    $DataFolder = \"$env:AllUsersProfile\\Application Data\"",
          "  }",
          "  $TempFolder = \"/\"",
          "  if ( $env:Temp -ne $null ) {",
          "    $TempFolder = $env:Temp",
          "  }",
          "  $DataFolder = Join-Path $DataFolder 'Amazon\\SSM'",
          "  $UpdateFolder = Join-Path $TempFolder 'Amazon\\SSM'",
          "  if ( !( Test-Path -LiteralPath $DataFolder )) {",
          "    $none = New-Item -ItemType directory -Path $DataFolder",
          "  }",
          "  $DataACL = Get-Acl $DataFolder",
          "  if ( Test-Path -LiteralPath $UpdateFolder ) {",
          "    $UpdateACL = Get-Acl $UpdateFolder",
          "    $ACLDiff = Compare-Object ($UpdateACL.AccessToString) ($DataACL.AccessToString)",
          "    if ( $ACLDiff.count -eq 0 ) {",
          "      exit 0",
          "    }",
          "    Remove-Item $UpdateFolder -Recurse -Force",
          "  }",
          "  $none = New-Item -ItemType directory -Path $UpdateFolder",
          "  Set-Acl $UpdateFolder -aclobject $DataACL",
          "  $UpdateACL = Get-Acl $UpdateFolder",
          "  $ACLDiff = Compare-Object ($UpdateACL.AccessToString) ($DataACL.AccessToString)",
          "  if ( $ACLDiff.count -ne 0 ) {",
          "    Write-Error \"Failed to create update folder\" -ErrorAction Continue",
          "    exit 41",
          "  }",
          "} catch {",
          "  Write-Host  \"Failed to create update folder\"",
          "  Write-Error  $Error[0]  -ErrorAction Continue",
          "  exit 42",
          "}"
        ]
      }
    },
    {
      "action": "aws:updateSsmAgent",
      "name": "awsupdateSsmAgent",
      "inputs": {
        "agentName": "amazon-ssm-agent",
        "source": "https://s3.{Region}.amazonaws.com/amazon-ssm-{Region}/ssm-agent-manifest.json",
        "allowDowngrade": "{{ allowDowngrade }}",
        "targetVersion": "{{ version }}"
      }
    }
  ]
}
DOC
}

resource "aws_ssm_association" "ssm-associate" {
  name = aws_ssm_document.ssm-access.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.bastion.id]
  }
}
