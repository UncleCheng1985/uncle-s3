"""Host structural/package/negative tests, NOT a device emulator. No third-party deps."""
import hashlib,json,re,shutil,struct,sys,tempfile,unittest,zipfile
from pathlib import Path
KIT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(KIT/'tools'))
import uncle,assets,demo_assets

class KitTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.project=uncle.new_project(KIT/'templates/sdk-starter',self.root/'my-test')
    def tearDown(self):self.tmp.cleanup()
    def change_manifest(self,**values):
        p=self.project/'game.json';m=json.loads(p.read_text());m.update(values);p.write_text(json.dumps(m),encoding='utf8')
    def test_all_examples_and_template(self):
        for p in list((KIT/'examples').iterdir())+list((KIT/'templates').iterdir()):
            if p.is_dir():uncle.check(p)
    def test_api_reference_and_declarations_are_complete(self):
        schema=json.loads((KIT/'api/api.json').read_text());names={f['name'] for f in schema['functions']}
        self.assertEqual(len(names),44)
        audit=json.loads((KIT/'api/runtime-audit.json').read_text());self.assertEqual(names,set(audit['functions']))
        declarations=set(re.findall(r'^function ([\w.]+)\(', (KIT/'api/uncle.lua').read_text(),re.M))
        self.assertEqual(names,declarations)
        doc=(KIT/'docs/API.md').read_text()
        for name in names:self.assertIn('## `'+name+'(',doc)
    def test_new_identity_and_no_overwrite(self):
        m,_,_=uncle.check(self.project);self.assertEqual(m['id'],'my-test')
        with self.assertRaises(ValueError):uncle.new_project(KIT/'templates/sdk-starter',self.project)
        with self.assertRaises(ValueError):uncle.new_project(KIT/'templates/sdk-starter',self.root/'blockfall')
    def test_manifest_boundaries(self):
        for change in [dict(id='other'),dict(api=True),dict(api=2),dict(orientation='square'),dict(title='x'*64),dict(entry='../main.lua'),dict(assets='missing.bvp')]:
            old=(self.project/'game.json').read_bytes();self.change_manifest(**change)
            with self.assertRaises(ValueError):uncle.check(self.project)
            (self.project/'game.json').write_bytes(old)
    def test_duplicate_keys_and_unicode_escape(self):
        p=self.project/'game.json';original=p.read_text()
        for text in [original.replace('"api": 1','"api": 1, "api": 1'),original.replace('My Test',r'My \u0054est')]:
            p.write_text(text,encoding='utf8')
            with self.assertRaises(ValueError):uncle.check(self.project)
    def test_entry_size_and_blocked_and_unknown_api(self):
        p=self.project/'main.lua';original=p.read_text()
        for suffix in ['\nio.open("file")','\nrequire("socket")','\ngfx.sprite(1,2,3)','\nvocab.ready()']:
            p.write_text(original+suffix,encoding='utf8')
            with self.assertRaises(ValueError):uncle.check(self.project)
        p.write_bytes(b'x'*65537)
        with self.assertRaises(ValueError):uncle.check(self.project)
    def test_allowlist_saves_and_paths(self):
        plan=self.project/'project.json';old=plan.read_bytes()
        for name in ['../outside.txt','save.dat','progress.log','secret.env']:
            if '/' not in name:(self.project/name).write_text('private')
            j=json.loads(old);j['files'].append(name);plan.write_text(json.dumps(j))
            with self.assertRaises(ValueError):uncle.check(self.project)
        plan.write_bytes(old)
    def test_package_layout_hashes_and_preserved_saves(self):
        (self.project/'save.dat').write_text('best=7\n');(self.project/'private.env').write_text('not included')
        output=self.root/'game.zip';inventory,_=uncle.package(self.project,output)
        with zipfile.ZipFile(output) as z:
            self.assertIn('Games/my-test/game.json',z.namelist())
            self.assertNotIn('Games/my-test/save.dat',z.namelist())
            self.assertNotIn('Games/my-test/private.env',z.namelist())
            for row in inventory:self.assertEqual(hashlib.sha256(z.read(row['path'])).hexdigest(),row['sha256'])
        self.assertEqual((self.project/'save.dat').read_text(),'best=7\n')
        with self.assertRaises(FileExistsError):uncle.package(self.project,output)
    def test_original_assets_rebuild_and_corruption(self):
        source=demo_assets.generate(self.root/'assets-src');pack=assets.build(source/'pack.json',self.root/'assets.bvp')
        self.assertEqual(pack.read_bytes(),(KIT/'examples/coin-dash/assets.bvp').read_bytes())
        self.assertEqual(uncle.pack_entries(pack),{'coin':1,'collect':5})
        data=bytearray(pack.read_bytes());data[-1]^=1;pack.write_bytes(data)
        with self.assertRaises(ValueError):uncle.pack_entries(pack)
    def test_bad_cover_and_audio(self):
        p=self.root/'bad.bvc';p.write_bytes(b'BVC1')
        with self.assertRaises(ValueError):uncle.cover(p)
        uncle.wav_file(KIT/'resources/coin-dash-source/collect.wav')
    def test_document_links(self):
        for p in KIT.rglob('*.md'):
            text=p.read_text(encoding='utf8');self.assertEqual(text.count('```')%2,0,p)
            for name in re.findall(r'\]\(([^)]+)\)',text):
                if name.startswith(('http:','https:','#')):continue
                self.assertTrue((p.parent/name.split('#')[0]).is_file(),(p,name))

if __name__=='__main__':unittest.main()
