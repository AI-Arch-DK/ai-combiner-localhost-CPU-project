# Network Templates — FAQ кэш (network.db)

Темы предвычисленных ответов в `network.db/templates`. Генерируются через `qwen-bg` / `hf+qwen` и кэшируются.

## MikroTik

| Тема | ID |
|---|---|
| OSPF настройка | `faq_mikrotik_ospf` |
| BGP настройка | `faq_mikrotik_bgp` |
| IP Cloud / удалённый доступ без IP | `faq_mikrotik_cloud` |
| VLAN настройка | `faq_mikrotik_vlan` |

## Keenetic

| Тема | ID |
|---|---|
| xray-core через Entware + xkeen | `faq_keenetic_xkeen` |
| WireGuard настройка | `faq_keenetic_wg` |

## VPN / Туннели

| Тема | ID |
|---|---|
| VLESS Reality настройка | `faq_vless_reality` |

## Pentest (kali-нода)

| Тема | ID |
|---|---|
| Network reconnaissance | `faq_pentest_network_recon` |
| Lateral movement | `faq_pentest_lateral_movement` |
| AD Kerberoasting | `faq_pentest_ad_kerberoasting` |
| AD ASREPRoasting | `faq_pentest_ad_asreproasting` |
| Password spray | `faq_pentest_password_spray` |
| C2 frameworks | `faq_pentest_c2_frameworks` |
| SMTP auth bypass | `faq_pentest_smtp_auth_bypass` |
| AiTM phishing | `faq_pentest_aitm_phishing` |
| Email recon | `faq_pentest_email_recon` |
| Vuln assessment | `faq_pentest_vuln_assessment` |
| POP3 attacks | `faq_pentest_pop3_attacks` |
| SMTP relay | `faq_pentest_smtp_relay` |

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
