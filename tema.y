%{
#include <stdio.h>
     #include <string.h>
//#include "header.h"

	int lineNo = 1;
	int colNo = 1;

int yylex();
	int yyerror(const char *msg);

     int EsteCorecta = 1;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     bool initialized;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1,bool init = false);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1,bool init = false);
             int getValue(char* n);
	     void setValue(char* n, int v);
	     void read(char* n);
             int isInit(char* n);
	};

	TVAR* TVAR::head = NULL;
	TVAR* TVAR::tail = NULL;

	
	void TVAR::read(char* n)
	{
		int x;
		this->setValue(n,1); //pun 1 si e ca si cum ar fi initalizata 
	}

	TVAR::TVAR(char* n, int v,bool init)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->initialized = init;
	 this->next = NULL;
	}

	int TVAR::isInit(char* n)
	{
	 TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0 && tmp->initialized == true)
	      return 1;
	     tmp = tmp->next;
	   }
	   return -1;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v,bool init)
	 {
	   TVAR* elem = new TVAR(n, v,init);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
		tmp->initialized = true; //am initializat variabila
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;

%}

%union { int intVal;
 char* strVal; }

%token TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_ATTRIBUTE TOK_ADD TOK_MINUS TOK_MUL TOK_DIV TOK_LEFT TOK_RIGHT TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_ERROR TOK_POINT

%token <intVal> TOK_INT
%token <strVal> TOK_ID

%type <intVal> Exp
%type <intVal> Factor
%type <intVal> Term
%type <strVal> IDList


%left TOK_ADD TOK_MINUS
%left TOK_MUL TOK_DIV

%start S


%%

S : TOK_PROGRAM ID TOK_VAR DeclList TOK_BEGIN StmtList TOK_END TOK_POINT
 ;

ID : TOK_ID;	

DeclList : DeclList ';' Decl
	| error ';' Decl {printf("Tip de date inexistent, sau eroare la declaratie, linia %d \n",lineNo -1); EsteCorecta = 0; } //daca nu a intrat in eroare de declaratie gresita, tipul de date este gresit
     | Decl   
	
    ;
	

	

Decl : IDList ':' Type
{
	char* c =strtok($1,",");
	
	
	while(c!=NULL)
		{

		if(ts != NULL)
		{

			if(ts->exists(c) == 0)
				ts->add(c); //le adaug neinitialziate
			else
			{
				EsteCorecta = 0;
			   sprintf(msg,"Linia %d: Coloana%d Eroare semantica: Declaratii multiple pentru variabila %s!", lineNo,colNo, c);
			    yyerror(msg);
	  			
			}
		}
		else
		{
			 ts = new TVAR();
	 		 ts->add(c); //le adaug neinitializate
		}
		
	c=strtok(NULL,",");

	}
	 	

}
	| error ':' Type { printf("Eroare la declareea variabilelor! Linia: %d \n ",lineNo);  EsteCorecta = 0; }
		
;
Type : TOK_INTEGER
;
StmtList : Stmt 
     	 | StmtList ';' Stmt
         | error ';' Stmt   { EsteCorecta = 0; }
	;

Stmt : Read
    | Attribute

    | Write
    | FOR  
	
    ;

Attribute : TOK_ID TOK_ATTRIBUTE Exp
{

if(ts == NULL) //verific daca fac atribuire pe o variabila care exista
{ 
sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila %s nu a fost declarata!", lineNo, colNo, $1);
	EsteCorecta = 0;
	    yyerror(msg);
	   
	
}
else if ( ts->exists($1) == 0)
{

sprintf(msg,"Linia %d:Eroare semantica: Variabila %s! nu a fost declarata!", lineNo, $1);
	EsteCorecta = 0;
	    yyerror(msg);
	   
}

	if(ts != NULL)
	{
		if(ts->exists($1) == 1) //daca exista
		{
			ts->setValue($1,$3); // o initializez
		
			
		}
	}



}
  ;

Exp : Term {$$ = $1;}
     | Exp TOK_ADD Term { $$ = $1 + $3;}
     | Exp TOK_MINUS Term {$$ = $1 - $3;}
     ;

Term : Factor { $$ = $1;}
     | Term TOK_MUL Factor { $$ = $1 * $3;}
     | Term TOK_DIV Factor 
{
	if( $3 == 0)
	{
			EsteCorecta = 0;
		printf("Eroare semantica: impartire la 0!");
		yyerror(msg);
		
	}
	else
	$$ = $1 / $3;
}
;

Factor : TOK_ID 
	{
	
	if( ts != NULL)
	{
		if(ts->exists($1))
		{
			if( ts->isInit($1) > 0)
				$$ = ts->getValue($1);
			else
				{

				sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila %s nu a fost initializata!", lineNo, colNo, $1);
					EsteCorecta = 0;
		 		   yyerror(msg);
	  				
				}
		}
		else
		{
		EsteCorecta = 0;
		sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila %s nu a fost declarata!", lineNo,colNo, $1);
					EsteCorecta = 0;
		 		   yyerror(msg);
	  				
		}
	}
	else
	{
	EsteCorecta = 0;
	sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila %s nu a fost declarata!", lineNo, colNo, $1);
		EsteCorecta = 0;
		   yyerror(msg);
	  		
	
	}
	
}
	
    | TOK_INT { $$ = $1; }
    | TOK_LEFT Exp TOK_RIGHT { $$ = $2; }
;

Read : TOK_READ TOK_LEFT IDList TOK_RIGHT
{
	char* c =strtok($3,",");
	
	int declared =-1; //pp ca nu e declarata
	while(c!=NULL)
		{
		declared = -1;
		if(ts != NULL)
		{

			declared++;
			if(ts->exists(c)) //daca e declarata
				{
				
				ts->read(c); //daca o am in tabela pot face cititrea
		
				declared++;
				}
		}

		
		if(declared < 1) //nedeclarata
		{
	sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila  %s nu a fost declarata!", lineNo, colNo, c);

	EsteCorecta = 0;
	   yyerror(msg);
	 

		}
		
	c=strtok(NULL,",");
	}

} ;



Write : TOK_WRITE TOK_LEFT IDList TOK_RIGHT
{
	char* c =strtok($3,",");
	
	int declared =-1; //pp ca nu e declarata
	int init = 1; //pp ca e initializata
	while(c!=NULL)
		{
		declared = -1;
		init = 1;
		if(ts != NULL)
		{

			declared++;
			if(ts->exists(c)) //verific sa fie declarata
				{
				if(ts->isInit(c) < 0) //verific sa fie initializata
				init = -1; //nu a fost initializata

				declared++;
				}
		}

		if( declared < 1 || init == -1) //Cazurile de eroare
	{	
		if(declared < 1) //nedeclarata
		{
	sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila  %s nu a fost declarata!", lineNo, colNo, c);
		}

		if(init == -1) //neinitializata
	sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila  %s nu a fost initializata!", lineNo, colNo, c);

	EsteCorecta = 0;
	   yyerror(msg);
	  

	}
		
	c=strtok(NULL,",");
	}

			
} ;


IDList : TOK_ID {strcpy($$,$1);}
      |
      IDList ',' TOK_ID {  strcat($$,","); strcat($$,$3);}
     


;

FOR : TOK_FOR IExp TOK_DO Body;

IExp : TOK_ID TOK_ATTRIBUTE Exp TOK_TO Exp
{
	if(ts != NULL)
	{

	
		if(ts->exists($1))
			ts->setValue($1,$3);
		else
			{

			sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila  %s nu a fost declarata!", lineNo, colNo, $1);

			EsteCorecta = 0;
	 		  yyerror(msg);
	   		
			}

	}
	else
	{

			sprintf(msg,"Linia %d: Coloana %d Eroare semantica: Variabila  %s nu a fost declarata!", lineNo, colNo, $1);

			EsteCorecta = 0;
	 		  yyerror(msg);
	   		
	}


		
}
;

Body : Stmt
     | TOK_BEGIN StmtList TOK_END
   
;

%%

int main()
{
	

	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("Programul este corect!\n");		
	}	

	
       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}


