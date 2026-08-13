#!/usr/bin/env python3
"""
التنين المصحح - صياد إيثريوم حقيقي
يستخدم مفتاحك الفعلي ويصطاد العقود الجديدة.
"""

import requests
import time
import sqlite3
from light_analyzer import LightAnalyzer

# ==================== الإعدادات الحقيقية ====================
ETHERSCAN_API_KEY = "1PPN574A63FJI97VENARC17JH286WB9CQ8"  # مفتاحك هنا
ANALYZER = LightAnalyzer()
DB_NAME = "eth_victims.db"

# ==================== قاعدة البيانات ====================
class Database:
    def __init__(self):
        self.conn = sqlite3.connect(DB_NAME)
        self.cursor = self.conn.cursor()
        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS victims (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                address TEXT,
                vuln_type TEXT,
                severity TEXT
            )
        """)
        self.conn.commit()
    
    def log_victim(self, address, vuln_type, severity):
        self.cursor.execute("""
            INSERT INTO victims (timestamp, address, vuln_type, severity)
            VALUES (?, ?, ?, ?)
        """, (time.ctime(), address, vuln_type, severity))
        self.conn.commit()
        print(f"    💾 سجلت الضحية: {address} ({vuln_type})")

# ==================== ماسح الإيثريوم ====================
class EtherscanScanner:
    BASE_URL = "https://api.etherscan.io/v2/api"
    
    def __init__(self, api_key):
        self.api_key = api_key
        self.db = Database()
    
    def get_latest_contracts(self, limit=10):
        """جلب أحدث العقود المنشورة"""
        print("🌐 جلب أحدث العقود من الإيثريوم...")
        url = f"{self.BASE_URL}?chainid=1&module=contract&action=getcontractcreation&apikey={self.api_key}&page=1&offset={limit}"
        
        try:
            response = requests.get(url, timeout=10)
            data = response.json()
            
            if data.get('status') == '1' and data.get('result'):
                contracts = []
                for item in data['result']:
                    contracts.append({
                        'address': item.get('contractAddress', ''),
                        'creator': item.get('contractCreator', ''),
                        'tx_hash': item.get('txHash', '')
                    })
                print(f"✅ تم العثور على {len(contracts)} عقدًا.")
                return contracts
            else:
                print(f"⚠️ لا توجد نتائج: {data.get('message', 'Unknown')}")
                return []
        except Exception as e:
            print(f"⚠️ خطأ في جلب العقود: {e}")
            return []
    
    def get_contract_source(self, address):
        """جلب الكود المصدري لعقد"""
        url = f"{self.BASE_URL}?chainid=1&module=contract&action=getsourcecode&address={address}&apikey={self.api_key}"
        
        try:
            response = requests.get(url, timeout=10)
            data = response.json()
            
            if data.get('status') == '1' and data.get('result'):
                source = data['result'][0].get('SourceCode', '')
                contract_name = data['result'][0].get('ContractName', 'Unknown')
                return source, contract_name
            return "", ""
        except Exception as e:
            print(f"    ⚠️ خطأ في جلب المصدر: {e}")
            return "", ""
    
    def hunt(self, num_contracts=10):
        """دورة صيد كاملة"""
        print("🐉 التنين المصحح يستيقظ...")
        print("=" * 50)
        
        contracts = self.get_latest_contracts(num_contracts)
        
        if not contracts:
            print("❌ لا توجد عقود للفحص.")
            return
        
        victims_found = 0
        
        for contract in contracts:
            address = contract['address']
            if not address:
                continue
            
            print(f"\n🔍 فحص العقد: {address}")
            source, name = self.get_contract_source(address)
            
            if not source or source == "Contract source code not verified":
                print(f"  ⚠️ الكود غير متاح أو غير مُتحقق منه.")
                time.sleep(0.2)
                continue
            
            print(f"  📄 اسم العقد: {name}")
            
            # تنظيف الكود المصدري (قد يكون بصيغة JSON)
            if source.startswith('{'):
                try:
                    import json
                    source_json = json.loads(source)
                    if 'sources' in source_json:
                        source = source_json['sources'][0]['content']
                except:
                    pass
            
            findings = ANALYZER.analyze(source)
            
            if findings:
                victims_found += 1
                print(f"  🚨 ثغرات: {len(findings)}")
                for f in findings:
                    print(f"    - {f['type']} ({f['severity']}): {f['desc']}")
                    self.db.log_victim(address, f['type'], f['severity'])
            else:
                print(f"  ✅ نظيف")
            
            time.sleep(0.3)  # احترام حدود API
        
        print("\n" + "=" * 50)
        print(f"🎯 انتهى الصيد. الضحايا: {victims_found}")

# ==================== التشغيل ====================
if __name__ == "__main__":
    hunter = EtherscanScanner(ETHERSCAN_API_KEY)
    hunter.hunt(10)
