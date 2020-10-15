create or replace procedure send_email( message in varchar2)
as
l_smtp_server varchar2(1024) := 'email-smtp.us-east-1.amazonaws.com';
l_smtp_port number := 587;
l_wallet_dir varchar2(128) := 'S3_WALLET';
l_from varchar2(128) := '<email>'; 
l_to varchar2(128) := '<email>'; 
l_user varchar2(128) := 'username'; 
l_password varchar2(128) := 'password'; 
l_subject varchar2(128) := message;
l_wallet_path varchar2(4000);
l_conn utl_smtp.connection;
l_reply utl_smtp.reply;
l_replies utl_smtp.replies;
begin
select 'file:/' || directory_path into l_wallet_path from
dba_directories where directory_name=l_wallet_dir;

-- open a connection
l_reply := utl_smtp.open_connection(
host => l_smtp_server,
port => l_smtp_port,
c => l_conn,
wallet_path => l_wallet_path,
secure_connection_before_smtp => false
);
dbms_output.put_line('opened connection, received reply ' ||
l_reply.code || '/' || l_reply.text);

-- get supported configs from server
l_replies := utl_smtp.ehlo(l_conn, 'localhost');
for r in 1..l_replies.count loop
dbms_output.put_line('ehlo (server config) : ' ||
l_replies(r).code || '/' || l_replies(r).text);
end loop;
dbms_output.put_line('TEST BREAK');
-- STARTTLS
l_reply := utl_smtp.starttls(l_conn);
dbms_output.put_line('starttls, received reply ' ||
l_reply.code || '/' || l_reply.text);

--
l_replies := utl_smtp.ehlo(l_conn, 'localhost');
for r in 1..l_replies.count loop
dbms_output.put_line('ehlo (server config) : ' ||
l_replies(r).code || '/' || l_replies(r).text);
end loop;

utl_smtp.auth(l_conn, l_user, l_password,
utl_smtp.all_schemes);

utl_smtp.mail(l_conn, l_from);
utl_smtp.rcpt(l_conn, l_to);
utl_smtp.open_data(l_conn);
utl_smtp.write_data(l_conn, 'Date: ' || to_char(SYSDATE, 'DDMON-YYYYHH24:MI:SS') || utl_tcp.crlf);
utl_smtp.write_data(l_conn, 'From: ' || l_from ||utl_tcp.crlf);
utl_smtp.write_data(l_conn, 'To: ' || l_to || utl_tcp.crlf);
utl_smtp.write_data(l_conn, 'Subject: ' || l_subject ||utl_tcp.crlf);
utl_smtp.write_data(l_conn, '' || utl_tcp.crlf);
utl_smtp.write_data(l_conn, 'Test message.' || utl_tcp.crlf);

utl_smtp.close_data(l_conn);

l_reply := utl_smtp.quit(l_conn);
exception
when others then
utl_smtp.quit(l_conn);
raise;
end;
/