const fs = require('fs');
const path = require('path');

class Reporter {
  constructor(name) { this.name = name; this.results = []; }
  pass(test, detail = '') { this.results.push({test,status:'PASS',detail}); }
  fail(test, error) { this.results.push({test,status:'FAIL',detail:error?.message || String(error)}); }
  skip(test, detail) { this.results.push({test,status:'SKIP',detail}); }
  print() {
    for (const r of this.results) console.log(`${r.status.padEnd(4)} ${r.test}${r.detail ? ` — ${r.detail}` : ''}`);
    const passed=this.results.filter(x=>x.status==='PASS').length;
    const failed=this.results.filter(x=>x.status==='FAIL').length;
    const skipped=this.results.filter(x=>x.status==='SKIP').length;
    console.log(`\n${this.name}: ${passed} passed, ${failed} failed, ${skipped} skipped`);
    return failed === 0;
  }
  writeReport() {
    const dir=path.join(__dirname,'..','reports'); fs.mkdirSync(dir,{recursive:true});
    const file=path.join(dir,`${this.name.replace(/[^a-z0-9_-]+/gi,'-')}-${Date.now()}.json`);
    fs.writeFileSync(file,JSON.stringify({name:this.name,createdAt:new Date().toISOString(),results:this.results},null,2));
    return file;
  }
}
module.exports = Reporter;
