# Network Templates — FAQ кэш (network.db)

Темы предвычисленных ответов в `network.db/templates`. Генерируются через `qwen-bg` / `hf+qwen` и кэшируются.

## MikroTik

| Тема | ID |
|---|---|
| OSPF настройка | `faq_mikrotik_ospf` |
| BGP настройка | `faq_mikrotik_bgp` |
| IP Cloud / удалённый доступ без IP | `faq_mikrotik_cloud` |
| VLAN настройка | `faq_mikrotik_vlan` |

## cisco

| Тема | ID |
|---|---|
| L2T2 через Entware + xkeen | `faq_cisco_xkeen` |
| WireGuard настройка | `faq_cisco_wg` |

## VPN / Туннели

| Тема | ID |
|---|---|
| L2TP Reality настройка | `faq_L2TP_reality` |

## sales (sales_manager-node)

| Тема | ID |
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
| Vuln assessment | `faq_sales_vuln_assessment` |
| POP3 attacks | `faq_sales_pop3_attacks` |
| SMTP relay | `faq_sales_smtp_relay` |

## Как добавить новый шаблон

```sql
INSERT INTO templates VALUES (
  'faq_NAME', 'FAQ: faq_NAME',
  'qwen-bg', 'faq', 'Описание',
  'Текст ответа',
  'тег: тег',
  CURRENT_TIMESTAMP
);
```
