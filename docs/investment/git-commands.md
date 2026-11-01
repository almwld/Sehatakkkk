# أوامر إدارة حزمة الاستثمار

> نفّذ الأوامر من نسخة محلية موثوقة. جميع التغييرات تبقى على الفرع `investment/technical-due-diligence-v0.1`. لا تدمج إلى `master` أو أي فرع إنتاج.

```bash
git clone https://github.com/almwld/Sehatakkkk.git
cd Sehatakkkk
git fetch origin
git switch investment/technical-due-diligence-v0.1

git status --short
# راجع التغييرات قبل الإضافة
git add docs/investment/html docs/investment/assets docs/investment/git-commands.md
git commit -m "docs(investment): complete investment HTML package"
git push origin investment/technical-due-diligence-v0.1
```

## التحقق من الفرع وعدم الدمج

```bash
git branch --show-current
git log -1 --oneline
git status --short
git ls-remote --heads origin investment/technical-due-diligence-v0.1
```

يجب أن يعرض الأمر الأول الفرع المحدد أعلاه. لا تنفّذ `git merge` أو `git push origin master` ضمن هذه المهمة.

## معاينة الملفات على GitHub

- `docs/investment/html/executive-summary.html`
- `docs/investment/html/report-full.html`
- `docs/investment/assets/`

## تنبيه
لا تستخدم `git add .` إذا كانت نسخة العمل تحتوي ملفات أسرار أو ملفات بناء أو بيانات شخصية. أضف المسارات المقصودة فقط، وافحص `git diff --cached` قبل الالتزام.