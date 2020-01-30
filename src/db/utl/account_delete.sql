delete from account where 
email_id in (select email.id from email
    where email = 'yarin.nim@gmail.com');


delete from email where email = 'yarin.nim@gmail.com';

