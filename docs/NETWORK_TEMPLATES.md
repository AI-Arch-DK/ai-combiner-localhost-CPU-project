# Network Templates — FAQ Cache (network.db)

Pre-computed answer topics stored in `network.db/templates`. Generated via `qwen-bg` / `hf+qwen` and cached.

## MikroTik

| Topic | ID |
|---|---|
| OSPF setup | `faq_mikrotik_ospf` |
| BGP setup | `faq_mikrotik_bgp` |
| IP Cloud / remote access without static IP | `faq_mikrotik_cloud` |
| VLAN setup | `faq_mikrotik_vlan` |

## Cisco

| Topic | ID |
|---|---|
| L2TP via Entware + xkeen | `faq_cisco_xkeen` |
| WireGuard setup | `faq_cisco_wg` |

## VPN / Tunnels

| Topic | ID |
|---|---|
| L2TP Reality setup | `faq_L2TP_reality` |

## Security Research (sales_manager-node)

| Topic | ID |
|---|---|
| Network reconnaissance | `faq_sales_network_recon` |
| Lateral movement | `faq_sales_lateral_movement` |
| AD Kerberoasting | `faq_sales_ad_kerberoasting` |
| AD ASREPRoasting | `faq_sales_ad_asreproasting` |
| Password spray | `faq_sales_password_spray` |
| C2 frameworks | `faq_sales_c2_frameworks` |
| SMTP auth bypass | `faq_sales_smtp_auth_bypass` |
| AiTM phishing | `faq_sales_aitm_phishing` |
| Email recon | `faq_sales_email_recon` |
| Vulnerability assessment | `faq_sales_vuln_assessment` |
| POP3 attacks | `faq_sales_pop3_attacks` |
| SMTP relay | `faq_sales_smtp_relay` |

## Adding a New Template

```sql
INSERT INTO templates VALUES (
  'faq_NAME', 'FAQ: faq_NAME',
  'qwen-bg', 'faq', 'Description',
  'Answer text',
  'tag: tag',
  CURRENT_TIMESTAMP
);
```
