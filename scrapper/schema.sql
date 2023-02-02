create table if not exists messages(
	body text,
	date integer as (body->>'$.date'),
	from_id integer as (body->>'$.from_id'),
	attachments text as (body->>'$.attachments'),
	conversation_message_id integer as (body->>'$.conversation_message_id'),
	fwd_messages text as (body->>'$.fwd_messages'),
	reply_message text as (body->>'$.reply_message'),
	text text as (body->>'$.text')
);

create index if not exists messages_date_idx on messages(date);
create index if not exists messages_from_id_idx on messages(from_id);
create index if not exists messages_conversation_message_id_idx on
	messages(conversation_message_id);

create virtual table if not exists messages_fts using fts5(
	text,
	content='messages',
	content_rowid='conversation_message_id'
);

create trigger messages_fts_sync_insert after insert on messages begin
  insert into messages_fts(rowid, text) values (new.conversation_message_id, new.text);
end;

create trigger messages_fts_sync_delete after delete on messages begin
  delete from messages_fts where rowid = old.conversation_message_id;
end;

create trigger messages_fts_sync_update after update on messages begin
  delete from messages_fts where rowid = old.conversation_message_id;
  insert into messages_fts(rowid, text) values (new.conversation_message_id, new.text);
end;
