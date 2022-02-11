variable "ssh_file_path" {
	default = "./cred/ssh_key"
}

variable project_name {
  type        = string
  default     = "Training"
  description = "description"
}

variable instance_type {
  type        = string
  default     = "t2.small"
  description = "description"
}

variable instance_names {
  type        = list(string)
  default     = [
    "yamuna",
    "santhiya",
    "uzma",
    "kalyanee",
    "vanitha",
    "abirami"
        ]
  description = "description"
}


