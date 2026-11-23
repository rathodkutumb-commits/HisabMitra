-- Categories in both languages (app 1.3.0): an expense or income keeps its
-- category's Gujarati name too, so a phone that re-creates the category from
-- the record can show it in Gujarati. Nullable: records from older apps (and
-- categories without a Gujarati name) simply have none. apply_personal_op and
-- get_personal_snapshot copy columns generically, so no function changes.
alter table public.personal_transactions
  add column category_name_gu text check (char_length(category_name_gu) between 1 and 60);
