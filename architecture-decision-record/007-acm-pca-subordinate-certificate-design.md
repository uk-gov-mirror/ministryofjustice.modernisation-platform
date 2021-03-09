1. Record architecture decisions
 
Date: 2021-03-04
 
## Status
 
✅ Review
 
## Context
 
The Modernisation Platform requires a secure PKI management utility that supports the creation and management of internal private certificates and subordinates.

There are many certificate options available, including third-party certificate authorities such as LetEncrypt. ACM is an AWS certificate management tool that lets you easily, manage and deploy TLS/SSL certificates for use with AWS services. ACM allows for easy integration with existing AWS load balancers, CloudFront distributions, and API Gateway, allowing ACM to manage the lifecycle of the certificate. EC2 instances are not managed by ACM and require the private certificate to be exported and installed locally on the EC2 instance. This will not be controlled by ACM and will need its own method of certificate lifecycle management to be setup.

LetsEncrypt offers a free certificate management service that can be integrated into ACM. The service requires access to a third-party vendor in order for the root and subordinate certificates to be managed. A local agent (certbot) is also required to be inst
 
 
## Decision
 
We have decided to use AWS ACM as our Private CA. This decision was based on a discovery exercise:
 
- Ease of use and integration. ACM is offered as an AWS service and has good integration with existing services such as CloudFront and Elastic Load balancers. The product is easy to configure and does not require additional third-party connectivity. 
 
- Centrally managed and self-contained within the AWS eco-system
 
- ACM offers free public/private certificates for use with integrated AWS services
 
ACM PCA does have a cost associated with the setup and management of the private root CA and subordinate certificates. There will be 2 private subordinate certificates, one for the live (production and preproduction) and a seperate certificate for non-live (test and development). 
 
We believe the costs associated with setting up an ACM PCA are as follows:
 
1 x private root CA
1 x private subordinate CA (live)
1 x private subordinate CA (non-live)
 
We estimate the monthly cost associated with managing an ACM private CA for the modernisation platform to be base on the current pricing model.
 
3 x $400 = $1200 per month
 
https://aws.amazon.com/certificate-manager/pricing/
 
 
## Consequences
 
We need to ensure the platform can support in-transit encryption of data, both internally and externally
