
import xmlrpc.client
import threading
import time
import random
import ssl

# --- إعدادات الاتصال بالسيرفر ---
URL = "https://abdo-erp.local"
DB = "abdo"
USER = "admin"  # اكتب هنا اسم مستخدم له صلاحيات (غالبا admin)
PASS = "admin"  # اكتب هنا باسورده

# --- إعدادات الحمل ---
NUMBER_OF_USERS = 50       # عدد الموظفين المتزامنين
OPERATIONS_PER_USER = 10    # كل موظف هيعمل 5 دورات كاملة (بيع/شراء/تصنيع)

print(f"🚀 بدء محاكاة حركة الموظفين الحقيقية على داتا بيز: {DB}...")

# الاتصال ببوابة أودو لتوثيق المستخدمين
common = xmlrpc.client.ServerProxy(f'{URL}/xmlrpc/2/common', context=ssl._create_unverified_context())
uid = common.authenticate(DB, USER, PASS, {})
models = xmlrpc.client.ServerProxy(f'{URL}/xmlrpc/2/object', context=ssl._create_unverified_context())
if not uid:
    print("❌ خطأ: لم يتم الاتصال، تأكد من اسم المستخدم والباسورد وقاعدة البيانات!")
    exit()

print(f"🔒 تم تسجيل الدخول بنجاح كـ Admin (UID: {uid})")

# جلب بعض البيانات الأساسية من السيرفر عشان نستخدمها في العمليات
try:
    partner_ids = models.execute_kw(DB, uid, PASS, 'res.partner', 'search', [[]], {'limit': 5})
    product_ids = models.execute_kw(DB, uid, PASS, 'product.product', 'search', [[('sale_ok', '=', True)]], {'limit': 5})
except Exception as e:
    print(f"❌ خطأ أثناء جلب بيانات المنتجات أو العملاء: {e}")
    exit()

def simulate_user_behavior(user_id):
    for op in range(OPERATIONS_PER_USER):
        try:
            partner = random.choice(partner_ids)
            product = random.choice(product_ids)
            
            # --- 1. عملية البيع (Sale Order) ---
            sale_id = models.execute_kw(DB, uid, PASS, 'sale.order', 'create', [{
                'partner_id': partner,
                'order_line': [(0, 0, {
                    'product_id': product,
                    'product_uom_qty': random.randint(1, 5),
                    'price_unit': random.randint(100, 500),
                })]
            }])
            # تأكيد أمر البيع ليصبح حقيقي
            models.execute_kw(DB, uid, PASS, 'sale.order', 'action_confirm', [[sale_id]])
            print(f"👤 الموظف [{user_id}]: أنشأ وأكد أمر بيع رقم #{sale_id} 💰")

            # --- 2. عملية الشراء (Purchase Order) ---
            purchase_id = models.execute_kw(DB, uid, PASS, 'purchase.order', 'create', [{
                'partner_id': partner,
                'order_line': [(0, 0, {
                    'product_id': product,
                    'product_qty': random.randint(10, 50),
                    'price_unit': random.randint(50, 200),
                    'date_planned': time.strftime('%Y-%m-%d %H:%M:%S'),
                })]
            }])
            # تأكيد أمر الشراء
            models.execute_kw(DB, uid, PASS, 'purchase.order', 'button_confirm', [[purchase_id]])
            print(f"👤 الموظف [{user_id}]: أنشأ وأكد أمر شراء رقم #{purchase_id} 🛒")

            # --- 3. عملية التصنيع (Manufacturing Order) ---
            # ملحوظة: تحتاج لموديول التصنيع MRP ومكونات للمنتج
            try:
                mo_id = models.execute_kw(DB, uid, PASS, 'mrp.production', 'create', [{
                    'product_id': product,
                    'product_qty': random.randint(1, 10),
                    'product_uom_id': 1, # الوحدة الافتراضية
                }])
                print(f"👤 الموظف [{user_id}]: أنشأ أمر تصنيع للمنتج رقم #{mo_id} ⚙️")
            except Exception:
                # لو موديول التصنيع مش متسطب الكود هيكمل عادي بدون ما يقف
                pass

            time.sleep(random.uniform(0.5, 1.5)) # محاكاة حركة الماوس والتفكير للموظف البشري

        except Exception as e:
            print(f"⚠️ الموظف [{user_id}] واجه مشكلة في العملية: {e}")

# تشغيل الـ Threads (الموظفين المتزامنين)
threads = []
start_time = time.time()

for i in range(1, NUMBER_OF_USERS + 1):
    t = threading.Thread(target=simulate_user_behavior, args=(i,))
    threads.append(t)
    t.start()

for t in threads:
    t.join()

end_time = time.time()
print("\n" + "="*50)
print(f"🏁 تم الانتهاء من المحاكاة بنجاح!")
print(f"⏱️ الوقت المستغرق: {end_time - start_time:.2f} ثانية.")
print(f"📊 اذهب الآن لمتصفحك وافتح شاشات المبيعات والمشتريات لتشاهد الإنجاز!")
print("="*50)
