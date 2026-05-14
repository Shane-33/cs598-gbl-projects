import pandas as pd
import numpy as np
from tqdm import tqdm
from transformers import T5Tokenizer, T5EncoderModel
import torch

device = "cuda" if torch.cuda.is_available() else "cpu"
local_path = '/shared/nas2/anna19/class_project'

df_3di    = pd.read_csv(local_path + '/uniprot_dataset/3di_tokens/uniprot_3di.csv')
df_labels = pd.read_csv(local_path + '/uniprot_dataset/3di_tokens/uniprot_dataset_filtered_labels.csv')

tokenizer = T5Tokenizer.from_pretrained('Rostlab/ProstT5', do_lower_case=False)
model = T5EncoderModel.from_pretrained('Rostlab/ProstT5', torch_dtype=torch.float16, use_safetensors=True)
model = model.to(torch.float32).to(device)
num_hidden_size = model.config.hidden_size  # 1024
feat_cols = [f'Feature_{i+1}' for i in range(num_hidden_size)]
print(f'ProstT5 loaded on {device}, hidden_size={num_hidden_size}')

tokens_lookup = df_3di.set_index('uniprot_id')['3di_tokens'].to_dict()
proteins = [p for p in df_labels['uniprot_id'].unique() if p in tokens_lookup]
print(f'Proteins to embed: {len(proteins)}')

rows = []
for prot_id in tqdm(proteins):
    tokens_str = tokens_lookup[prot_id]
    prot_labels = df_labels[df_labels['uniprot_id'] == prot_id]

    # "<fold2AA>" prefix signals structural-token input to ProstT5
    prostt5_input = "<fold2AA> " + " ".join(tokens_str.lower())
    token_encoding = tokenizer(prostt5_input, return_tensors="pt",
                               add_special_tokens=False).to(device)
    try:
        with torch.no_grad():
            out = model(**token_encoding)
    except RuntimeError:
        print(f"RuntimeError for {prot_id} (L={len(tokens_str)})")
        continue

    # Strip prefix token (position 0) — same as PDB pipeline
    emb = out.last_hidden_state.detach().cpu().numpy().squeeze()[1:, :]

    for _, row in prot_labels.iterrows():
        idx = int(row['residue_number']) - 1   # 1-indexed → 0-indexed
        if idx < 0 or idx >= len(emb):
            continue
        entry = {
            'uniprot_id':     prot_id,
            'residue_letter': row['residue_letter'],
            'residue_number': row['residue_number'],
            '3di_token':      tokens_str[idx],
            'label':          row['label'],
        }
        for j, val in enumerate(emb[idx]):
            entry[feat_cols[j]] = val
        rows.append(entry)

df_out = pd.DataFrame(rows)
out_path = local_path + '/uniprot_dataset/3di_tokens/uniprot_dataset_foldseek3di.csv'
df_out.to_csv(out_path, index=False)
print(f'Saved {len(df_out)} rows to {out_path}')
