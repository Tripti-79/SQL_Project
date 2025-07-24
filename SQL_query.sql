-- trigger created for status updation 
create or replace trigger convicted_updation
after update of role_in_crime on criminal_crime_link
for each row
BEGIN
    if :new.role_in_crime='convicted' then
    update INVESTIGATIONS set status='closed' where CASE_ID= :new.case_id;
    update cases set status='solved' where case_id= :new.case_id;
    end if;
end;

-- case report for solved cases
select c.case_id,c.case_type,w.WITNESS_ID,w.witness_name,w.contact,w.statement from cases c,witness w where c.case_id=w.CASE_ID and c.STATUS='solved' order by case_id ; 

select c.case_id,c.case_type,e.evidence_type,e.description evidence_get,o.oname collected_by_officer,e.COLLECTED_BY_OID officer_id,o.contact officer_contact  from cases c,evidence e, investigations i,officers o where o.officer_id=e.COLLECTED_BY_OID and c.case_id=i.CASE_ID and i.investigat_id=e.investigat_id and c.status='solved' 
    order by c.CASE_ID ;

-- case report for unsolved cases   
select c.case_id,c.case_type,w.WITNESS_ID,w.witness_name,w.contact,w.statement from cases c,witness w where c.case_id=w.CASE_ID and c.STATUS='open' order by case_id ; 

select c.case_id,c.case_type,e.evidence_type,e.description evidence_get,o.oname collected_by_officer,e.COLLECTED_BY_OID officer_id,o.contact officer_contact  from cases c,evidence e, investigations i,officers o where o.officer_id=e.COLLECTED_BY_OID and c.case_id=i.CASE_ID and i.investigat_id=e.investigat_id and c.status='open' order by c.CASE_ID ;


-- case happened on which date and location . Also display  investigating officer of that cases . 
select c.case_id,c.case_type,to_char(c.case_date,'dd-mm-yyyy')case_date,c.location,o.oname investigating_officer,o.contact from cases c,officers o where c.INVESTIGAT_OFFICER_ID=o.officer_id and c.status='open' order by case_id ;

-- list of cases with victim's details and the criminal who is found convicted .
select v.vname victim,v.contact,v.location victim_residence,c.case_type,cr.cname criminal,cr.CRIMINAL_ID,cr.arrest_date from VICTIMS v,cases c,criminals cr,CRIMINAL_CRIME_LINK ccl,CASE_VICTIM_LINK cvl where c.CASE_ID=ccl.CASE_ID and cr.CRIMINAL_ID=ccl.CRIMINAL_ID and cvl.VICTIM_ID=v.VICTIM_ID and c.case_id=cvl.case_id and ccl.role_in_crime='accused' order by c.CASE_TYPE; 

-- No. of criminals associated with role_in_crime .
select count(criminal_id)number_of_criminals , role_in_crime from CRIMINAL_CRIME_LINK group by ROLE_IN_CRIME

-- view is created  for list of officers involved in unsolved cases. 
create view officers_involvement as select t1.case_id,t1.case_type,t1.investigat_officer_id officer_id,t1.oname list_of_officers_work_in_such_cases,t1.department,t1.rank_detail from (select c.case_id,c.case_type,c.investigat_officer_id,o.oname,o.DEPARTMENT,o.rank_detail from cases c,officers o where o.officer_id=c.investigat_officer_id and 
c.status='open' union select c.case_id,c.case_type,e.COLLECTED_BY_OID,o.oname,o.DEPARTMENT,o.rank_detail 
from cases c,evidence e, investigations i,officers o where o.officer_id=e.COLLECTED_BY_OID and c.case_id=i.CASE_ID and 
i.investigat_id=e.investigat_id and c.status='open' union 
select c.case_id,c.CASE_type,ch.submitted_by,o.oname,o.department,o.rank_detail from cases c,CHARGESHEET ch,officers o where c.CASE_ID=ch.CASE_ID and o.officer_id=ch.submitted_by and c.STATUS='open' )t1 order by t1.case_id ;