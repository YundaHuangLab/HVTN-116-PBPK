# =============================================================================
# HVTN 116 PBPK Model Code  
# All mrgsolve model for VRC01 and VRC01LS
# =============================================================================

# =============================================================================
# 1. VRC01 Female Model
# =============================================================================

VRC01_MODEL_CODE <- "
$PROB
A minimal PBPK model to predict exposure of VRC01 with deep/slow mucosal ISF subspaces (rectum/vagina/cervix)

$GLOBAL
double g_Vcentral_serum;
double g_Vlymph;
double g_VE;
double g_Ve1;
double g_Ve2;
double g_Ve3;
double g_REC_IV;
double g_VAG_IV;
double g_CER_IV;

double g_REC_DV;
double g_VAG_DV;
double g_CER_DV;



$PARAM @annotated
// {Physiological Parameters}
TVVcentral_serum    : 2.6       : Central serum volume (L)
TVVisf             : 15.6      : Interstitial fluid volume (L)
TVVrec             : 0.021     : Rectum tissue volume (L)
TVVvag             : 0.026     : Vagina tissue volume (L)
TVVcer             : 0.0253    : Cervix tissue volume (L)
TVVrec_blood       : 0.0022    : Rectum blood volume (L)
TVVvag_blood       : 0.01      : Vagina blood volume (L)
TVVcer_blood       : 0.009375  : Cervix blood volume (L)
TVQrec             : 8.1504    : Rectum blood flow (L/day)
TVQvag             : 3.6       : Vagina blood flow (L/day)
TVQcer             : 5.78      : Cervix blood flow (L/day)

TVVlymph           : 5.2       : Volume of lymph (L)
TVL                : 2.9       : Total lymph flow (L/day)
TVKp               : 0.8       : Fraction of interstitial space available for antibody distribution
TVKp_en            : 0.8       : Fraction of interstitial space available for Endogenous IgG distribution

TVRfT              : 0.945     : Vascular reflection coefficient for tight tissues
TVRfL              : 0.697     : Vascular reflection coefficient for leaky tissues
TVRflymph          : 0.2       : Lymphatic vascular reflection coefficient for mAb and Endo IgG

// FcRn + Endosome
FcRn_tot_central_serum    : 40000     : Total FcRn concentration in central serum endosome (nM)
FcRn_tot_rec       : 40000     : Total FcRn concentration in rectum endosome (nM)
FcRn_tot_vag       : 40000     : Total FcRn concentration in vagina endosome (nM)
FcRn_tot_cer       : 40000     : Total FcRn concentration in cervix endosome (nM)

TVVe1              : 0.000105  : Endosome volume rectum (L)
TVVe2              : 0.00013   : Endosome volume vagina (L)
TVVe3              : 0.0001265 : Endosome volume cervix (L)

// mAb kinetics
TVkup_A            : 1.0       : mAb central serum uptake rate constant (1/day)
TVkdeg_A           : 10        : mAb central serum degradation rate constant (1/day)
TVkdeg_t_A         : 500       : mAb tissue degradation rate constant (1/day)
krecy_A            : 138.62    : mAb recycling rate constant (1/day), FIXED
TVVE               : 0.31      : Endosome volume for nonspecific pinocytosis (L) for central_serum
TVkon_A            : 18.84     : Antibody FcRn association rate constant (nM-1.day-1) in endosomes
TVkoff_A           : 4821      : Antibody-FcRn complex dissociation rate constant (1/day) in endosomes

// endogenous IgG kinetics
TVkup_en           : 1.0       : Endogenous IgG central serum uptake (1/day), FITTED
TVkdeg_en          : 3.13       : Endogenous IgG central serum degradation (1/day), FITTED
TVkup_t_en         : 1     : Endogenous IgG tissue uptake rate constant (1/day)
TVkdeg_t_en        : 3.13     : Endogenous IgG tissue degradation rate constant (1/day)
krecy_en           : 14.088    : Endogenous IgG recycling rate constant (1/day), FIXED
TVkon_en           : 8.12      : Endogenous IgG association rate constant (nM-1.day-1)
TVkoff_en          : 24106     : Endogenous IgG dissociation rate constant (1/day)
TVk0               : 15900     : mean IgG synthesis rate (nmol/day)

TVREC_IV           : 0.00315   : Rectum interstitial volume (L)
TVVAG_IV           : 0.0039    : Vagina interstitial volume (L)
TVCER_IV           : 0.00375   : Cervix interstitial volume (L)

// --- NEW: deep/slow mucosal ISF subspace (mAb only)
TVkdeep_in_rec     : 0.002 : ISF->deep rec (1/day)
TVkdeep_out_rec    : 0.025 : deep->ISF rec (1/day)
TVkdeep_in         : 0.01      : ISF -> deep uptake (1/day) (mAb)
TVkdeep_out        : 0.008     : deep -> ISF return (1/day) (mAb)
TVdeep_frac        : 1    : deep volume fraction of mucosal ISF (unitless)
TVendo_init_fold   : 1         : Fold on direct endogenous baseline initials (unitless)

//  C_ : concentration, without C_ in the beginning is amount
//  A_ : antibody; en_ : endogenous IgG; es: endosome

$CMT @annotated
A_central_serum           : Antibody in central serum (nmol)
A_central_serum_es        : Antibody in central serum endosome (nmol)
C_FcRn_A_central_serum    : FcRn–antibody complex in central serum endosome (nM)
central_serum_auc         : Central serum AUC (nM*day)

A_Tight            : Antibody in tight tissue (nmol)
A_Leaky            : Antibody in leaky tissue (nmol)
A_lymph            : Antibody in lymph (nmol)

A_rec_es           : Antibody in rectum endosome (nmol)
A_vag_es           : Antibody in vagina endosome (nmol)
A_cer_es           : Antibody in cervical endosome (nmol)

A_rec_blood        : Antibody in rectum vascular compartment (nmol)
A_vag_blood        : Antibody in vagina vascular compartment (nmol)
A_cer_blood        : Antibody in cervix vascular compartment (nmol)

C_FcRn_A_rec       : FcRn–antibody complex in rectum endosome (nM)
C_FcRn_A_vag       : FcRn–antibody complex in vagina endosome (nM)
C_FcRn_A_cer       : FcRn–antibody complex in cervix endosome (nM)

C_en_central_serum        : Endogenous IgG in central serum (nM)
C_en_central_serum_es     : Endogenous IgG in central serum endosome (nM)
C_FcRn_en_central_serum   : FcRn–endogenous IgG complex in central serum endosome (nM)

en_Tight           : Endogenous IgG in tight tissue (nmol)
en_Leaky           : Endogenous IgG in leaky tissue (nmol)
C_Ly_en            : Endogenous IgG in lymph (nM)

en_rec_blood       : Endogenous IgG in rectum vascular compartment (nmol)
C_en_rec_es        : Endogenous IgG in rectum endosome (nM)
C_FcRn_en_rec      : FcRn–endogenous IgG complex in rectum endosome (nM)

en_vag_blood       : Endogenous IgG in vagina vascular compartment (nmol)
C_en_vag_es        : Endogenous IgG in vagina endosome (nM)
C_FcRn_en_vag      : FcRn–endogenous IgG complex in vagina endosome (nM)

en_cer_blood       : Endogenous IgG in cervix vascular compartment (nmol)
C_en_cer_es        : Endogenous IgG in cervix endosome (nM)
C_FcRn_en_cer      : FcRn–endogenous IgG complex in cervix endosome (nM)

// mucosal ISF concentrations (nM)
C_A_rec_I          : mAb rectum ISF concentration (nM)
C_A_vag_I          : mAb vagina ISF concentration (nM)
C_A_cer_I          : mAb cervix ISF concentration (nM)

// --- NEW: deep/slow mucosal subspace concentrations (nM)
C_A_rec_D          : mAb rectum deep concentration (nM)
C_A_vag_D          : mAb vagina deep concentration (nM)
C_A_cer_D          : mAb cervix deep concentration (nM)

// endogenous mucosal ISF concentrations (nM)
C_en_rec_I         : Endogenous IgG rectum ISF concentration (nM)
C_en_vag_I         : Endogenous IgG vagina ISF concentration (nM)
C_en_cer_I         : Endogenous IgG cervix ISF concentration (nM)

// --- NEW: deep/slow endogenous IgG mucosal subspace concentrations (nM)
C_en_rec_D         : Endogenous IgG rectum deep concentration (nM)
C_en_vag_D         : Endogenous IgG vagina deep concentration (nM)
C_en_cer_D         : Endogenous IgG cervix deep concentration (nM)

A_mAb_degraded     : Cumulative amount of mAb degraded (nmol)
$OMEGA
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 

$MAIN

double Vlymph = TVVlymph * exp(ETA(1));
double L   =  TVL  * exp(ETA(2));

double Kp  =  0.8* exp(ETA(3));    
double RfT = TVRfT  * exp(ETA(4));
double RfL =  TVRfL   * exp(ETA(5));
double Rflymph =  TVRflymph   * exp(ETA(6));
double kup_A = TVkup_A * exp(ETA(7));
double kdeg_A = TVkdeg_A * exp(ETA(9));
double kdeg_t_A = TVkdeg_t_A * exp(ETA(10));
 
double kon_A  =  TVkon_A  * exp(ETA(12));
double koff_A = TVkoff_A   * exp(ETA(13));

double Vcentral_serum = TVVcentral_serum * exp(ETA(14));
double Visf = TVVisf * exp(ETA(15));
double VisfT = Visf*0.65;
double VisfL = Visf*0.35;
double LT = L*0.33;
double LL = L*0.67;

double Ve1  = TVVe1  * exp(ETA(11));
double Ve2  = TVVe2  * exp(ETA(16));
double Ve3  = TVVe3  * exp(ETA(17));

double Vrec = TVVrec * exp(ETA(18));
double Vvag = TVVvag * exp(ETA(19));
double Vcer = TVVcer * exp(ETA(20));
double Qrec = TVQrec * exp(ETA(21));
double Qvag = TVQvag * exp(ETA(22));
double Qcer = TVQcer * exp(ETA(23));
double Vrec_blood = TVVrec_blood * exp(ETA(24));
double Vvag_blood = TVVvag_blood * exp(ETA(25));
double Vcer_blood = TVVcer_blood * exp(ETA(26));

double kon_en   =  TVkon_en     * exp(ETA(27));
double koff_en  =  TVkoff_en     * exp(ETA(28));
double kup_en = TVkup_en * exp(ETA(29));
double kdeg_en = TVkdeg_en * exp(ETA(30));
double kup_t_en = TVkup_t_en * exp(ETA(31));
double kdeg_t_en = TVkdeg_t_en * exp(ETA(32));
double k0  =  TVk0 * exp(ETA(33));
double VE  =  TVVE * exp(ETA(34));

double Kp_en= TVKp_en * exp(ETA(35));
double fserum = 0.715;

// Mucosal reflection coefficients and volumes
double REC_VRC = 0.85;
double VAG_VRC = 0.85;
double CER_VRC = 0.85;

double REC_ISRC = 0.2;
double VAG_ISRC = 0.2;
double CER_ISRC = 0.2;

double REC_IV = TVREC_IV;
double VAG_IV = TVVAG_IV;
double CER_IV = TVCER_IV;

double REC_LF = Qrec * 0.002;
double VAG_LF = Qvag * 0.002;
double CER_LF = Qcer * 0.002;

// --- NEW deep volumes (L)
double deep_frac = TVdeep_frac;
double REC_DV = deep_frac * REC_IV;
double VAG_DV = deep_frac * VAG_IV;
double CER_DV = deep_frac * CER_IV;

// --- NEW deep exchange rates
double kdeep_in  = TVkdeep_in;
double kdeep_out = TVkdeep_out;
double kdeep_in_rec  = TVkdeep_in_rec;
double kdeep_out_rec = TVkdeep_out_rec;


// Clearances from rate constants × blood volumes
double CLup_A = kup_A * Vcentral_serum;
double CLup_en = kup_en * Vcentral_serum;

double CLup_rec = kup_A * Vrec_blood;
double CLup_vag = kup_A * Vvag_blood;
double CLup_cer = kup_A * Vcer_blood;

double CLup_en_rec = kup_t_en * Vrec_blood;
double CLup_en_vag = kup_t_en * Vvag_blood;
double CLup_en_cer = kup_t_en * Vcer_blood;

// Direct endogenous baseline init (female) with optional high-IgG fold.
double endo_init_fold = TVendo_init_fold;
C_en_central_serum_0 = 61754;
en_rec_blood_0     = 61848 * Vrec_blood;
en_vag_blood_0     = 61702 * Vvag_blood;
en_cer_blood_0     = 61768 * Vcer_blood;

C_en_central_serum_es_0 = 15075;
C_Ly_en_0 = 13740;

en_Tight_0 = 4246 * (15.6 * 0.65 * 0.8);
en_Leaky_0 = 23389 * (15.6 * 0.35 * 0.8);

C_en_rec_es_0      = 309445;
C_en_vag_es_0      = 1473135;
C_en_cer_es_0      = 1444798;

C_en_rec_I_0       = 11018;
C_en_vag_I_0       = 5550;
C_en_cer_I_0       = 6840;

C_en_rec_D_0       = 0;
C_en_vag_D_0       = 0;
C_en_cer_D_0       = 0;

C_FcRn_en_central_serum_0 = 33415;
if (C_FcRn_en_central_serum_0 > FcRn_tot_central_serum) C_FcRn_en_central_serum_0 = FcRn_tot_central_serum;

C_FcRn_en_rec_0 = 39620;
if (C_FcRn_en_rec_0 > FcRn_tot_rec) C_FcRn_en_rec_0 = FcRn_tot_rec;

C_FcRn_en_vag_0 = 39920;
if (C_FcRn_en_vag_0 > FcRn_tot_vag) C_FcRn_en_vag_0 = FcRn_tot_vag;

C_FcRn_en_cer_0 = 39918;
if (C_FcRn_en_cer_0 > FcRn_tot_cer) C_FcRn_en_cer_0 = FcRn_tot_cer;

// Save globals for TABLE mass-balance
g_Vlymph = Vlymph;
g_Vcentral_serum = Vcentral_serum;
g_VE = VE;
g_Ve1 = Ve1;
g_Ve2 = Ve2;
g_Ve3 = Ve3;
g_REC_IV = REC_IV;
g_VAG_IV = VAG_IV;
g_CER_IV = CER_IV;
g_REC_DV = REC_DV;
g_VAG_DV = VAG_DV;
g_CER_DV = CER_DV;

$ODE

double C_A_rec_blood = A_rec_blood / Vrec_blood;
double C_A_vag_blood = A_vag_blood / Vvag_blood;
double C_A_cer_blood = A_cer_blood / Vcer_blood;

double C_en_rec_blood = en_rec_blood / Vrec_blood;
double C_en_vag_blood = en_vag_blood / Vvag_blood;
double C_en_cer_blood = en_cer_blood / Vcer_blood;

double L_total = L + REC_LF + VAG_LF + CER_LF;

// Free FcRn (nM)
double C_FcRn_central_serum = FcRn_tot_central_serum - C_FcRn_A_central_serum - C_FcRn_en_central_serum;
if(C_FcRn_central_serum < 0.0) C_FcRn_central_serum = 0.0;

double C_FcRn_rec = FcRn_tot_rec - C_FcRn_A_rec - C_FcRn_en_rec;
if(C_FcRn_rec < 0.0) C_FcRn_rec = 0.0;

double C_FcRn_vag = FcRn_tot_vag - C_FcRn_A_vag - C_FcRn_en_vag;
if(C_FcRn_vag < 0.0) C_FcRn_vag = 0.0;

double C_FcRn_cer = FcRn_tot_cer - C_FcRn_A_cer - C_FcRn_en_cer;
if(C_FcRn_cer < 0.0) C_FcRn_cer = 0.0;

// --- Central mAb
dxdt_A_central_serum =
  L_total*A_lymph/Vlymph
  -Qrec*A_central_serum/Vcentral_serum + (Qrec-REC_LF)*A_rec_blood/Vrec_blood
  -Qvag*A_central_serum/Vcentral_serum + (Qvag-VAG_LF)*A_vag_blood/Vvag_blood
  -Qcer*A_central_serum/Vcentral_serum + (Qcer-CER_LF)*A_cer_blood/Vcer_blood
  -(1-RfT)*LT*A_central_serum/Vcentral_serum
  -(1-RfL)*LL*A_central_serum/Vcentral_serum
  -CLup_A*A_central_serum/Vcentral_serum
  +krecy_A*VE*C_FcRn_A_central_serum;

dxdt_A_central_serum_es =
  -kon_A*(A_central_serum_es/VE)*C_FcRn_central_serum*VE
  +koff_A*C_FcRn_A_central_serum*VE
  -kdeg_A*A_central_serum_es
  +CLup_A*A_central_serum/Vcentral_serum;

dxdt_C_FcRn_A_central_serum =
  kon_A*C_FcRn_central_serum*(A_central_serum_es/VE)
  -koff_A*C_FcRn_A_central_serum
  -krecy_A*C_FcRn_A_central_serum;

// --- Central endogenous IgG (central_serum conc nM)
dxdt_C_en_central_serum =
  (1/Vcentral_serum) * (
    k0 + L_total*C_Ly_en
    -Qrec*C_en_central_serum + (Qrec-REC_LF)*en_rec_blood/Vrec_blood
    -Qvag*C_en_central_serum + (Qvag-VAG_LF)*en_vag_blood/Vvag_blood
    -Qcer*C_en_central_serum + (Qcer-CER_LF)*en_cer_blood/Vcer_blood
    -(1-RfT)*LT*C_en_central_serum
    -(1-RfL)*LL*C_en_central_serum
    -CLup_en*C_en_central_serum
    +krecy_en*VE*C_FcRn_en_central_serum
  );

dxdt_C_en_central_serum_es =
  (1/VE) * (
    -kon_en*C_en_central_serum_es*VE*C_FcRn_central_serum
    +koff_en*C_FcRn_en_central_serum*VE
    +CLup_en*C_en_central_serum
    -kdeg_en*C_en_central_serum_es*VE
  );

dxdt_C_FcRn_en_central_serum =
  kon_en*C_FcRn_central_serum*C_en_central_serum_es
  -koff_en*C_FcRn_en_central_serum
  -krecy_en*C_FcRn_en_central_serum;

// --- Tight/leaky lumped tissues (mAb + endo)
dxdt_A_Tight = (1-RfT)*LT*A_central_serum/Vcentral_serum - (1-Rflymph)*LT*A_Tight/(VisfT*Kp);
dxdt_A_Leaky = (1-RfL)*LL*A_central_serum/Vcentral_serum - (1-Rflymph)*LL*A_Leaky/(VisfL*Kp);

dxdt_A_lymph =
  (1-Rflymph)*LT*A_Tight/(VisfT*Kp) +
  (1-Rflymph)*LL*A_Leaky/(VisfL*Kp) +
  (1-REC_ISRC)*REC_LF*C_A_rec_I +
  (1-VAG_ISRC)*VAG_LF*C_A_vag_I +
  (1-CER_ISRC)*CER_LF*C_A_cer_I+
  -L_total*A_lymph/Vlymph;

dxdt_en_Tight = (1-RfT)*LT*C_en_central_serum - (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en);
dxdt_en_Leaky = (1-RfL)*LL*C_en_central_serum - (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en);

dxdt_C_Ly_en =
  (
    (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en) +
    (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en) +
    (1-REC_ISRC)*REC_LF*C_en_rec_I +
    (1-VAG_ISRC)*VAG_LF*C_en_vag_I +
    (1-CER_ISRC)*CER_LF*C_en_cer_I
    -L_total*C_Ly_en
  ) / Vlymph;

// --- Rectum vascular + endosome (mAb)
dxdt_A_rec_blood =
  Qrec*A_central_serum/Vcentral_serum
  -(1-REC_VRC)*REC_LF*(A_rec_blood/Vrec_blood)
  -CLup_rec*A_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*A_rec_blood/Vrec_blood
  +fserum*krecy_A*C_FcRn_A_rec*Ve1;

dxdt_A_rec_es =
  -kon_A*(A_rec_es/Ve1)*C_FcRn_rec*Ve1
  +koff_A*C_FcRn_A_rec*Ve1
  -kdeg_t_A*A_rec_es
  +CLup_rec*C_A_rec_I
  +CLup_rec*A_rec_blood/Vrec_blood;

dxdt_C_FcRn_A_rec =
  kon_A*C_FcRn_rec*(A_rec_es/Ve1)
  -koff_A*C_FcRn_A_rec
  -krecy_A*C_FcRn_A_rec;

// --- Rectum vascular + endosome (endo)
dxdt_en_rec_blood =
  Qrec*C_en_central_serum
  -(1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood)
  -CLup_en_rec*en_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*en_rec_blood/Vrec_blood
  +fserum*krecy_en*C_FcRn_en_rec*Ve1;

dxdt_C_en_rec_es =
  (1/Ve1) * (
    -kon_en*C_en_rec_es*Ve1*C_FcRn_rec
    +koff_en*C_FcRn_en_rec*Ve1
    +CLup_en_rec*(en_rec_blood/Vrec_blood)
    +CLup_en_rec*C_en_rec_I
    -kdeg_t_en*C_en_rec_es*Ve1
  );

dxdt_C_FcRn_en_rec =
  kon_en*C_FcRn_rec*C_en_rec_es
  -koff_en*C_FcRn_en_rec
  -krecy_en*C_FcRn_en_rec;

// --- Vagina vascular + endosome (mAb)
dxdt_A_vag_blood =
  Qvag*A_central_serum/Vcentral_serum
  -(1-VAG_VRC)*VAG_LF*(A_vag_blood/Vvag_blood)
  -CLup_vag*A_vag_blood/Vvag_blood
  -(Qvag-VAG_LF)*A_vag_blood/Vvag_blood
  +fserum*krecy_A*C_FcRn_A_vag*Ve2;

dxdt_A_vag_es =
  -kon_A*(A_vag_es/Ve2)*C_FcRn_vag*Ve2
  +koff_A*C_FcRn_A_vag*Ve2
  -kdeg_t_A*A_vag_es
  +CLup_vag*C_A_vag_I
  +CLup_vag*A_vag_blood/Vvag_blood;

dxdt_C_FcRn_A_vag =
  kon_A*C_FcRn_vag*(A_vag_es/Ve2)
  -koff_A*C_FcRn_A_vag
  -krecy_A*C_FcRn_A_vag;

// --- Vagina vascular + endosome (endo)
dxdt_en_vag_blood =
  Qvag*C_en_central_serum
  -(1-VAG_VRC)*VAG_LF*(en_vag_blood/Vvag_blood)
  -CLup_en_vag*en_vag_blood/Vvag_blood
  -(Qvag-VAG_LF)*en_vag_blood/Vvag_blood
  +fserum*krecy_en*C_FcRn_en_vag*Ve2;

dxdt_C_en_vag_es =
  (1/Ve2) * (
    -kon_en*C_en_vag_es*Ve2*C_FcRn_vag
    +koff_en*C_FcRn_en_vag*Ve2
    +CLup_en_vag*(en_vag_blood/Vvag_blood)
    +CLup_en_vag*C_en_vag_I
    -kdeg_t_en*C_en_vag_es*Ve2
  );

dxdt_C_FcRn_en_vag =
  kon_en*C_FcRn_vag*C_en_vag_es
  -koff_en*C_FcRn_en_vag
  -krecy_en*C_FcRn_en_vag;

// --- Cervix vascular + endosome (mAb)
dxdt_A_cer_blood =
  Qcer*A_central_serum/Vcentral_serum
  -(1-CER_VRC)*CER_LF*(A_cer_blood/Vcer_blood)
  -CLup_cer*A_cer_blood/Vcer_blood
  -(Qcer-CER_LF)*A_cer_blood/Vcer_blood
  +fserum*krecy_A*C_FcRn_A_cer*Ve3;

dxdt_A_cer_es =
  -kon_A*(A_cer_es/Ve3)*C_FcRn_cer*Ve3
  +koff_A*C_FcRn_A_cer*Ve3
  -kdeg_t_A*A_cer_es
  +CLup_cer*C_A_cer_I
  +CLup_cer*A_cer_blood/Vcer_blood;

dxdt_C_FcRn_A_cer =
  kon_A*C_FcRn_cer*(A_cer_es/Ve3)
  -koff_A*C_FcRn_A_cer
  -krecy_A*C_FcRn_A_cer;

// --- Cervix vascular + endosome (endo)
dxdt_en_cer_blood =
  Qcer*C_en_central_serum
  -(1-CER_VRC)*CER_LF*(en_cer_blood/Vcer_blood)
  -CLup_en_cer*en_cer_blood/Vcer_blood
  -(Qcer-CER_LF)*en_cer_blood/Vcer_blood
  +fserum*krecy_en*C_FcRn_en_cer*Ve3;

dxdt_C_en_cer_es =
  (1/Ve3) * (
    -kon_en*C_en_cer_es*Ve3*C_FcRn_cer
    +koff_en*C_FcRn_en_cer*Ve3
    +CLup_en_cer*(en_cer_blood/Vcer_blood)
    +CLup_en_cer*C_en_cer_I
    -kdeg_t_en*C_en_cer_es*Ve3
  );

dxdt_C_FcRn_en_cer =
  kon_en*C_FcRn_cer*C_en_cer_es
  -koff_en*C_FcRn_en_cer
  -krecy_en*C_FcRn_en_cer;

// --- MUCOSAL ISF (mAb): with deep/slow subspace exchange
dxdt_C_A_rec_I =
  (((1 - REC_VRC) * REC_LF * C_A_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_A_rec_I) / REC_IV)
  - ((CLup_rec * C_A_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_A_rec_I
  + kdeep_out_rec * C_A_rec_D;

dxdt_C_A_vag_I =
  (((1 - VAG_VRC) * VAG_LF * C_A_vag_blood) / VAG_IV)
  - (((1 - VAG_ISRC) * VAG_LF * C_A_vag_I) / VAG_IV)
  - ((CLup_vag * C_A_vag_I) / VAG_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_vag * (Ve2 / VAG_IV))
  // deep exchange
  - kdeep_in * C_A_vag_I
  + kdeep_out * C_A_vag_D;

dxdt_C_A_cer_I =
  (((1 - CER_VRC) * CER_LF * C_A_cer_blood) / CER_IV)
  - (((1 - CER_ISRC) * CER_LF * C_A_cer_I) / CER_IV)
  - ((CLup_cer * C_A_cer_I) / CER_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_cer * (Ve3 / CER_IV))
  // deep exchange
  - kdeep_in * C_A_cer_I
  + kdeep_out * C_A_cer_D;

// --- NEW: deep compartments (mAb): mass-balanced via IV/DV scaling
dxdt_C_A_rec_D =
  kdeep_in_rec * C_A_rec_I * (REC_IV / REC_DV)
  - kdeep_out_rec * C_A_rec_D;

dxdt_C_A_vag_D =
  kdeep_in * C_A_vag_I * (VAG_IV / VAG_DV)
  - kdeep_out * C_A_vag_D;

dxdt_C_A_cer_D =
  kdeep_in * C_A_cer_I * (CER_IV / CER_DV)
  - kdeep_out * C_A_cer_D;

// --- MUCOSAL ISF (endo) unchanged
dxdt_C_en_rec_I =
  (((1 - REC_VRC) * REC_LF * C_en_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_en_rec_I) / REC_IV)
  - ((CLup_en_rec * C_en_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_en_rec_I;

dxdt_C_en_vag_I =
  (((1 - VAG_VRC) * VAG_LF * C_en_vag_blood) / VAG_IV)
  - (((1 - VAG_ISRC) * VAG_LF * C_en_vag_I) / VAG_IV)
  - ((CLup_en_vag * C_en_vag_I) / VAG_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_vag * (Ve2 / VAG_IV))
  // deep exchange
  - kdeep_in * C_en_vag_I;

dxdt_C_en_cer_I =
  (((1 - CER_VRC) * CER_LF * C_en_cer_blood) / CER_IV)
  - (((1 - CER_ISRC) * CER_LF * C_en_cer_I) / CER_IV)
  - ((CLup_en_cer * C_en_cer_I) / CER_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_cer * (Ve3 / CER_IV))
  // deep exchange
  - kdeep_in * C_en_cer_I;

// --- NEW: deep compartments (endogenous IgG)
dxdt_C_en_rec_D =0;

dxdt_C_en_vag_D =0;

dxdt_C_en_cer_D =0;
  
// Track cumulative mAb degradation
dxdt_A_mAb_degraded =
  kdeg_A*A_central_serum_es +
  kdeg_t_A*A_rec_es +
  kdeg_t_A*A_vag_es +
  kdeg_t_A*A_cer_es;

// AUC
dxdt_central_serum_auc = A_central_serum/Vcentral_serum;

$TABLE
double C_Central_Serum = (A_central_serum) / Vcentral_serum;
double C_Lymph  = A_lymph / Vlymph;

double Conc_en_central_serum = C_en_central_serum;
double C_en_lymph = C_Ly_en;

double C_A_Tight = A_Tight / (VisfT * Kp);
double C_A_Leaky = A_Leaky / (VisfL * Kp);

double C_en_tight = en_Tight / (VisfT * Kp_en);
double C_en_leaky = en_Leaky / (VisfL * Kp_en);

double conc_A_rec_I = C_A_rec_I;
double conc_A_vag_I = C_A_vag_I;
double conc_A_cer_I = C_A_cer_I;

double conc_A_rec_D = C_A_rec_D;
double conc_A_vag_D = C_A_vag_D;
double conc_A_cer_D = C_A_cer_D;

double C_en_REC_I = C_en_rec_I;
double C_en_VAG_I = C_en_vag_I;
double C_en_CER_I = C_en_cer_I;

double FcRn_total_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_total_rec = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;
double FcRn_total_vag = C_FcRn_vag + C_FcRn_A_vag + C_FcRn_en_vag;
double FcRn_total_cer = C_FcRn_cer + C_FcRn_A_cer + C_FcRn_en_cer; 

double FcRn_occ_mab_central_serum   = C_FcRn_A_central_serum  / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_endo_central_serum  = C_FcRn_en_central_serum / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_total_central_serum = (C_FcRn_A_central_serum + C_FcRn_en_central_serum) / (FcRn_tot_central_serum + 1e-9);
double FcRn_free_frac_central_serum = C_FcRn_central_serum    / (FcRn_tot_central_serum + 1e-9);

double FcRn_occ_mab_rec   = C_FcRn_A_rec  / (FcRn_tot_rec + 1e-9);
double FcRn_occ_endo_rec  = C_FcRn_en_rec / (FcRn_tot_rec + 1e-9);
double FcRn_occ_total_rec = (C_FcRn_A_rec + C_FcRn_en_rec) / (FcRn_tot_rec + 1e-9);
double FcRn_free_frac_rec = C_FcRn_rec    / (FcRn_tot_rec + 1e-9);

double FcRn_occ_mab_vag   = C_FcRn_A_vag  / (FcRn_tot_vag + 1e-9);
double FcRn_occ_endo_vag  = C_FcRn_en_vag / (FcRn_tot_vag + 1e-9);
double FcRn_occ_total_vag = (C_FcRn_A_vag + C_FcRn_en_vag) / (FcRn_tot_vag + 1e-9);
double FcRn_free_frac_vag = C_FcRn_vag    / (FcRn_tot_vag + 1e-9);

double FcRn_occ_mab_cer   = C_FcRn_A_cer  / (FcRn_tot_cer + 1e-9);
double FcRn_occ_endo_cer  = C_FcRn_en_cer / (FcRn_tot_cer + 1e-9);
double FcRn_occ_total_cer = (C_FcRn_A_cer + C_FcRn_en_cer) / (FcRn_tot_cer + 1e-9);
double FcRn_free_frac_cer = C_FcRn_cer    / (FcRn_tot_cer + 1e-9);

double FcRn_mass_balance_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_mass_balance_rec    = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;
double FcRn_mass_balance_vag    = C_FcRn_vag + C_FcRn_A_vag + C_FcRn_en_vag;
double FcRn_mass_balance_cer    = C_FcRn_cer + C_FcRn_A_cer + C_FcRn_en_cer;

 

// --- UPDATED overall mucosal concentrations include deep pool
double C_A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1) / Vrec;

double C_A_vag_Overall =
  (A_vag_blood + C_A_vag_I * g_VAG_IV + C_A_vag_D * g_VAG_DV + A_vag_es + C_FcRn_A_vag*Ve2) / Vvag;

double C_A_cer_Overall =
  (A_cer_blood + C_A_cer_I * g_CER_IV + C_A_cer_D * g_CER_DV + A_cer_es + C_FcRn_A_cer*Ve3) / Vcer;

double A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1);

double A_vag_Overall =
  (A_vag_blood + C_A_vag_I * g_VAG_IV + C_A_vag_D * g_VAG_DV + A_vag_es + C_FcRn_A_vag*Ve2);

double A_cer_Overall =
  (A_cer_blood + C_A_cer_I * g_CER_IV + C_A_cer_D * g_CER_DV + A_cer_es + C_FcRn_A_cer*Ve3);

// Endo overall unchanged (no deep pool for endo)
double C_en_REC_Overall = (en_rec_blood + C_en_rec_I * g_REC_IV + (C_en_rec_es + C_FcRn_en_rec)*Ve1) / Vrec;
double C_en_VAG_Overall = (en_vag_blood + C_en_vag_I * g_VAG_IV + (C_en_vag_es + C_FcRn_en_vag)*Ve2) / Vvag;
double C_en_CER_Overall = (en_cer_blood + C_en_cer_I * g_CER_IV + (C_en_cer_es + C_FcRn_en_cer)*Ve3) / Vcer;

// Total amounts (mAb): include deep pools for mass balance
double total_mAb_amount =
  A_central_serum +
  A_central_serum_es +
  C_FcRn_A_central_serum * g_VE +
  A_Tight + A_Leaky + A_lymph +
  A_rec_blood + A_vag_blood + A_cer_blood +
  A_rec_es + A_vag_es + A_cer_es +
  C_FcRn_A_rec * g_Ve1 + C_FcRn_A_vag * g_Ve2 + C_FcRn_A_cer * g_Ve3 +
  C_A_rec_I * g_REC_IV + C_A_vag_I * g_VAG_IV + C_A_cer_I * g_CER_IV +
  C_A_rec_D * g_REC_DV + C_A_vag_D * g_VAG_DV + C_A_cer_D * g_CER_DV;

double total_endo_amount =
  (C_en_central_serum * g_Vcentral_serum) +
  (C_en_central_serum_es * g_VE) +
  (C_FcRn_en_central_serum * g_VE) +
  en_Tight + en_Leaky +
  (C_Ly_en * g_Vlymph) +
  en_rec_blood + en_vag_blood + en_cer_blood +
  C_en_rec_I * g_REC_IV + C_en_vag_I * g_VAG_IV + C_en_cer_I * g_CER_IV +
  C_en_rec_es * g_Ve1 + C_en_vag_es * g_Ve2 + C_en_cer_es * g_Ve3 +
  C_FcRn_en_rec * g_Ve1 + C_FcRn_en_vag * g_Ve2 + C_FcRn_en_cer * g_Ve3;

double cumulative_mAb_input = 15000;
double mAb_in_body = total_mAb_amount;
double mAb_degraded = A_mAb_degraded;
double mAb_mass_balance = cumulative_mAb_input - (mAb_in_body + mAb_degraded);

$CAPTURE
C_Central_Serum C_Lymph C_A_Tight C_A_Leaky
Conc_en_central_serum C_en_lymph C_en_tight C_en_leaky

C_en_REC_I C_en_VAG_I C_en_CER_I
conc_A_rec_I conc_A_vag_I conc_A_cer_I
conc_A_rec_D conc_A_vag_D conc_A_cer_D

C_A_rec_Overall C_A_vag_Overall C_A_cer_Overall
A_rec_Overall A_vag_Overall A_cer_Overall

C_en_REC_Overall C_en_VAG_Overall C_en_CER_Overall

FcRn_occ_mab_central_serum FcRn_occ_endo_central_serum FcRn_occ_total_central_serum FcRn_free_frac_central_serum
FcRn_occ_mab_rec FcRn_occ_endo_rec FcRn_occ_total_rec FcRn_free_frac_rec
FcRn_occ_mab_vag FcRn_occ_endo_vag FcRn_occ_total_vag FcRn_free_frac_vag
FcRn_occ_mab_cer FcRn_occ_endo_cer FcRn_occ_total_cer FcRn_free_frac_cer

FcRn_mass_balance_central_serum FcRn_mass_balance_rec FcRn_mass_balance_vag FcRn_mass_balance_cer

total_mAb_amount total_endo_amount mAb_in_body mAb_degraded
mAb_mass_balance cumulative_mAb_input
"


# =============================================================================
# 2. VRC01 Male Model
# =============================================================================
# Same as female but WITHOUT vagina and cervix compartments
# ============================================================================= 

VRC01_MALE_MODEL_CODE <- "

$PROB
A minimal PBPK model to predict exposure of VRC01 with deep/slow mucosal ISF subspaces (rectum only (male model))

$GLOBAL
double g_Vcentral_serum;
double g_Vlymph;
double g_VE;
double g_Ve1;
 
double g_REC_IV;

double g_REC_DV;

$PARAM @annotated
// {Physiological Parameters}
TVVcentral_serum          : 2.6       : Central serum volume (L)
TVVisf             : 15.6      : Interstitial fluid volume (L)
TVVrec             : 0.021     : Rectum tissue volume (L)
TVVrec_blood       : 0.0022    : Rectum blood volume (L)
TVQrec             : 8.1504    : Rectum blood flow (L/day)
 
TVVlymph           : 5.2       : Volume of lymph (L)
TVL                : 2.9       : Total lymph flow (L/day)
TVKp               : 0.8       : Fraction of interstitial space available for antibody distribution
TVKp_en            : 0.8       : Fraction of interstitial space available for Endogenous IgG distribution

TVRfT              : 0.945     : Vascular reflection coefficient for tight tissues
TVRfL              : 0.697     : Vascular reflection coefficient for leaky tissues
TVRflymph          : 0.2       : Lymphatic vascular reflection coefficient for mAb and Endo IgG

// FcRn + Endosome
FcRn_tot_central_serum    : 40000     : Total FcRn concentration in central serum endosome (nM)
FcRn_tot_rec       : 40000     : Total FcRn concentration in rectum endosome (nM)

// mAb kinetics
TVkup_A            : 1.0       : mAb central serum uptake rate constant (1/day)
TVkdeg_A           : 10        : mAb central serum degradation rate constant (1/day)
TVkdeg_t_A         : 500       : mAb tissue degradation rate constant (1/day)
krecy_A            : 138.62    : mAb recycling rate constant (1/day), FIXED
TVVE               : 0.31      : Endosome volume for nonspecific pinocytosis (L) for central_serum
TVkon_A            : 18.84     : Antibody FcRn association rate constant (nM-1.day-1) in endosomes
TVkoff_A           : 4821      : Antibody-FcRn complex dissociation rate constant (1/day) in endosomes

// endogenous IgG kinetics
TVkup_en           : 1.0       : Endogenous IgG central serum uptake (1/day), FITTED
TVkdeg_en          : 1.2       : Endogenous IgG central serum degradation (1/day), FITTED
TVkup_t_en         : 149.0     : Endogenous IgG tissue uptake rate constant (1/day)
TVkdeg_t_en        : 388.3     : Endogenous IgG tissue degradation rate constant (1/day)
krecy_en           : 14.088    : Endogenous IgG recycling rate constant (1/day), FIXED
TVkon_en           : 8.12      : Endogenous IgG association rate constant (nM-1.day-1)
TVkoff_en          : 24106     : Endogenous IgG dissociation rate constant (1/day)
TVk0               : 15900     : mean IgG synthesis rate (nmol/day)
TVREC_IV           : 0.00315   : Rectum interstitial volume (L)
TVVe1              : 0.000105  : Endosome volume rectum (L)

// --- NEW: deep/slow mucosal ISF subspace (mAb only)
TVkdeep_in_rec     : 0.002 : ISF->deep rec (1/day)
TVkdeep_out_rec    : 0.025 : deep->ISF rec (1/day)
TVkdeep_in         : 0.01      : ISF -> deep uptake (1/day) (mAb)
TVkdeep_out        : 0.008     : deep -> ISF return (1/day) (mAb)
TVdeep_frac        : 1    : deep volume fraction of mucosal ISF (unitless)
TVendo_init_fold   : 1         : Fold on direct endogenous baseline initials (unitless)

//  C_ : concentration, without C_ in the beginning is amount
//  A_ : antibody; en_ : endogenous IgG; es: endosome

$CMT @annotated
A_central_serum           : Antibody in central serum (nmol)
A_central_serum_es        : Antibody in central serum endosome (nmol)
C_FcRn_A_central_serum    : FcRn–antibody complex in central serum endosome (nM)
central_serum_auc         : Central serum AUC (nM*day)

A_Tight            : Antibody in tight tissue (nmol)
A_Leaky            : Antibody in leaky tissue (nmol)
A_lymph            : Antibody in lymph (nmol)

A_rec_es           : Antibody in rectum endosome (nmol)

A_rec_blood        : Antibody in rectum vascular compartment (nmol)

C_FcRn_A_rec       : FcRn–antibody complex in rectum endosome (nM)

C_en_central_serum        : Endogenous IgG in central serum (nM)
C_en_central_serum_es     : Endogenous IgG in central serum endosome (nM)
C_FcRn_en_central_serum   : FcRn–endogenous IgG complex in central serum endosome (nM)

en_Tight           : Endogenous IgG in tight tissue (nmol)
en_Leaky           : Endogenous IgG in leaky tissue (nmol)
C_Ly_en            : Endogenous IgG in lymph (nM)

en_rec_blood       : Endogenous IgG in rectum vascular compartment (nmol)
C_en_rec_es        : Endogenous IgG in rectum endosome (nM)
C_FcRn_en_rec      : FcRn–endogenous IgG complex in rectum endosome (nM)

// mucosal ISF concentrations (nM)
C_A_rec_I          : mAb rectum ISF concentration (nM)

// --- NEW: deep/slow mucosal subspace concentrations (nM)
C_A_rec_D          : mAb rectum deep concentration (nM)

// endogenous mucosal ISF concentrations (nM)
C_en_rec_I         : Endogenous IgG rectum ISF concentration (nM)

// --- NEW: deep/slow endogenous IgG mucosal subspace concentrations (nM)
C_en_rec_D         : Endogenous IgG rectum deep concentration (nM)

A_mAb_degraded     : Cumulative amount of mAb degraded (nmol)
$OMEGA
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 

$MAIN

double Vlymph = TVVlymph * exp(ETA(1));
double L   =  TVL  * exp(ETA(2));

double Kp  =  0.8* exp(ETA(3));    
double RfT = TVRfT  * exp(ETA(4));
double RfL =  TVRfL   * exp(ETA(5));
double Rflymph =  TVRflymph   * exp(ETA(6));
double kup_A = TVkup_A * exp(ETA(7));
double kdeg_A = TVkdeg_A * exp(ETA(9));
double kdeg_t_A = TVkdeg_t_A * exp(ETA(10));
double Ve1  = TVVe1  * exp(ETA(11));
double kon_A  =  TVkon_A  * exp(ETA(12));
double koff_A = TVkoff_A   * exp(ETA(13));

double Vcentral_serum = TVVcentral_serum * exp(ETA(14));
double Visf = TVVisf * exp(ETA(15));
double VisfT = Visf*0.65;
double VisfL = Visf*0.35;
double LT = L*0.33;
double LL = L*0.67;

 
double Vrec = TVVrec * exp(ETA(18));
double Qrec = TVQrec * exp(ETA(21));
double Vrec_blood = TVVrec_blood * exp(ETA(24));
 


double kon_en   =  TVkon_en     * exp(ETA(27));
double koff_en  =  TVkoff_en     * exp(ETA(28));
double kup_en = TVkup_en * exp(ETA(29));
double kdeg_en = TVkdeg_en * exp(ETA(30));
double kup_t_en = TVkup_t_en * exp(ETA(31));
double kdeg_t_en = TVkdeg_t_en * exp(ETA(32));
double k0  =  TVk0 * exp(ETA(33));
double VE  =  TVVE * exp(ETA(34));

double Kp_en= TVKp_en * exp(ETA(35));
double fserum = 0.715;

// Mucosal reflection coefficients and volumes
double REC_VRC = 0.85;

double REC_ISRC = 0.2;

double REC_IV = TVREC_IV;

double REC_LF = Qrec * 0.002;

// --- NEW deep volumes (L)
double deep_frac = TVdeep_frac;
double REC_DV = deep_frac * REC_IV;

// --- NEW deep exchange rates
double kdeep_in  = TVkdeep_in;
double kdeep_out = TVkdeep_out;
double kdeep_in_rec  = TVkdeep_in_rec;
double kdeep_out_rec = TVkdeep_out_rec;


// Clearances from rate constants × blood volumes
double CLup_A = kup_A * Vcentral_serum;
double CLup_en = kup_en * Vcentral_serum;

double CLup_rec = kup_A * Vrec_blood;

double CLup_en_rec = kup_t_en * Vrec_blood;

// Direct endogenous baseline init (male) with optional high-IgG fold.
double endo_init_fold = TVendo_init_fold;
C_en_central_serum_0 = 62896;
en_rec_blood_0 = 62991 * Vrec_blood;

C_en_central_serum_es_0 = 16279;
C_Ly_en_0 = 13960;

en_Tight_0 = 4324 * (15.6 * 0.65 * 0.8);
en_Leaky_0 = 23822 * (15.6 * 0.35 * 0.8);

C_en_rec_es_0 = 318280;

C_en_rec_I_0 = 11202;

C_en_rec_D_0 = 0;

C_FcRn_en_central_serum_0 = 33827;
if (C_FcRn_en_central_serum_0 > FcRn_tot_central_serum) C_FcRn_en_central_serum_0 = FcRn_tot_central_serum;

C_FcRn_en_rec_0 = 39630;
if (C_FcRn_en_rec_0 > FcRn_tot_rec) C_FcRn_en_rec_0 = FcRn_tot_rec;

// Save globals for TABLE mass-balance
g_Vlymph = Vlymph;
g_Vcentral_serum = Vcentral_serum;
g_VE = VE;
g_Ve1 = Ve1;
 
g_REC_IV = REC_IV;
g_REC_DV = REC_DV;

$ODE

double C_A_rec_blood = A_rec_blood / Vrec_blood;

double C_en_rec_blood = en_rec_blood / Vrec_blood;

double L_total = L + REC_LF;

// Free FcRn (nM)
double C_FcRn_central_serum = FcRn_tot_central_serum - C_FcRn_A_central_serum - C_FcRn_en_central_serum;
if(C_FcRn_central_serum < 0.0) C_FcRn_central_serum = 0.0;

double C_FcRn_rec = FcRn_tot_rec - C_FcRn_A_rec - C_FcRn_en_rec;
if(C_FcRn_rec < 0.0) C_FcRn_rec = 0.0;



// --- Central mAb
dxdt_A_central_serum =
  L_total*A_lymph/Vlymph
  -Qrec*A_central_serum/Vcentral_serum + (Qrec-REC_LF)*A_rec_blood/Vrec_blood
  -(1-RfT)*LT*A_central_serum/Vcentral_serum
  -(1-RfL)*LL*A_central_serum/Vcentral_serum
  -CLup_A*A_central_serum/Vcentral_serum
  +krecy_A*VE*C_FcRn_A_central_serum;

dxdt_A_central_serum_es =
  -kon_A*(A_central_serum_es/VE)*C_FcRn_central_serum*VE
  +koff_A*C_FcRn_A_central_serum*VE
  -kdeg_A*A_central_serum_es
  +CLup_A*A_central_serum/Vcentral_serum;

dxdt_C_FcRn_A_central_serum =
  kon_A*C_FcRn_central_serum*(A_central_serum_es/VE)
  -koff_A*C_FcRn_A_central_serum
  -krecy_A*C_FcRn_A_central_serum;

// --- Central endogenous IgG (central_serum conc nM)
dxdt_C_en_central_serum =
  (1/Vcentral_serum) * (
    k0 + L_total*C_Ly_en
    -Qrec*C_en_central_serum + (Qrec-REC_LF)*en_rec_blood/Vrec_blood
    -(1-RfT)*LT*C_en_central_serum
    -(1-RfL)*LL*C_en_central_serum
    -CLup_en*C_en_central_serum
    +krecy_en*VE*C_FcRn_en_central_serum
  );

dxdt_C_en_central_serum_es =
  (1/VE) * (
    -kon_en*C_en_central_serum_es*VE*C_FcRn_central_serum
    +koff_en*C_FcRn_en_central_serum*VE
    +CLup_en*C_en_central_serum
    -kdeg_en*C_en_central_serum_es*VE
  );

dxdt_C_FcRn_en_central_serum =
  kon_en*C_FcRn_central_serum*C_en_central_serum_es
  -koff_en*C_FcRn_en_central_serum
  -krecy_en*C_FcRn_en_central_serum;

// --- Tight/leaky lumped tissues (mAb + endo)
dxdt_A_Tight = (1-RfT)*LT*A_central_serum/Vcentral_serum - (1-Rflymph)*LT*A_Tight/(VisfT*Kp);
dxdt_A_Leaky = (1-RfL)*LL*A_central_serum/Vcentral_serum - (1-Rflymph)*LL*A_Leaky/(VisfL*Kp);

dxdt_A_lymph =
  (1-Rflymph)*LT*A_Tight/(VisfT*Kp) +
  (1-Rflymph)*LL*A_Leaky/(VisfL*Kp) +
  (1-REC_ISRC)*REC_LF*C_A_rec_I +
  -L_total*A_lymph/Vlymph;

dxdt_en_Tight = (1-RfT)*LT*C_en_central_serum - (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en);
dxdt_en_Leaky = (1-RfL)*LL*C_en_central_serum - (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en);

dxdt_C_Ly_en =
  (
    (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en) +
    (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en) +
    (1-REC_ISRC)*REC_LF*C_en_rec_I +
    -L_total*C_Ly_en
  ) / Vlymph;

// --- Rectum vascular + endosome (mAb)
dxdt_A_rec_blood =
  Qrec*A_central_serum/Vcentral_serum
  -(1-REC_VRC)*REC_LF*(A_rec_blood/Vrec_blood)
  -CLup_rec*A_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*A_rec_blood/Vrec_blood
  +fserum*krecy_A*C_FcRn_A_rec*Ve1;

dxdt_A_rec_es =
  -kon_A*(A_rec_es/Ve1)*C_FcRn_rec*Ve1
  +koff_A*C_FcRn_A_rec*Ve1
  -kdeg_t_A*A_rec_es
  +CLup_rec*C_A_rec_I
  +CLup_rec*A_rec_blood/Vrec_blood;

dxdt_C_FcRn_A_rec =
  kon_A*C_FcRn_rec*(A_rec_es/Ve1)
  -koff_A*C_FcRn_A_rec
  -krecy_A*C_FcRn_A_rec;

// --- Rectum vascular + endosome (endo)
dxdt_en_rec_blood =
  Qrec*C_en_central_serum
  -(1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood)
  -CLup_en_rec*en_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*en_rec_blood/Vrec_blood
  +fserum*krecy_en*C_FcRn_en_rec*Ve1;

dxdt_C_en_rec_es =
  (1/Ve1) * (
    -kon_en*C_en_rec_es*Ve1*C_FcRn_rec
    +koff_en*C_FcRn_en_rec*Ve1
    +CLup_en_rec*(en_rec_blood/Vrec_blood)
    +CLup_en_rec*C_en_rec_I
    -kdeg_t_en*C_en_rec_es*Ve1
  );

dxdt_C_FcRn_en_rec =
  kon_en*C_FcRn_rec*C_en_rec_es
  -koff_en*C_FcRn_en_rec
  -krecy_en*C_FcRn_en_rec;





// --- MUCOSAL ISF (mAb): with deep/slow subspace exchange
dxdt_C_A_rec_I =
  (((1 - REC_VRC) * REC_LF * C_A_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_A_rec_I) / REC_IV)
  - ((CLup_rec * C_A_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_A_rec_I
  + kdeep_out_rec * C_A_rec_D;

// --- NEW: deep compartments (mAb): mass-balanced via IV/DV scaling
dxdt_C_A_rec_D =
  kdeep_in_rec * C_A_rec_I  
  - kdeep_out_rec * C_A_rec_D;

// --- MUCOSAL ISF (endo) unchanged
dxdt_C_en_rec_I =
  (((1 - REC_VRC) * REC_LF * C_en_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_en_rec_I) / REC_IV)
  - ((CLup_en_rec * C_en_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_en_rec_I;

// --- NEW: deep compartments (endogenous IgG)
dxdt_C_en_rec_D =0;

  
// Track cumulative mAb degradation
dxdt_A_mAb_degraded =
  kdeg_A*A_central_serum_es +
  kdeg_t_A*A_rec_es;

// AUC
dxdt_central_serum_auc = A_central_serum/Vcentral_serum;

$TABLE
double C_Central_Serum = (A_central_serum) / Vcentral_serum;
double C_Lymph  = A_lymph / Vlymph;

double Conc_en_central_serum = C_en_central_serum;
double C_en_lymph = C_Ly_en;

double C_A_Tight = A_Tight / (VisfT * Kp);
double C_A_Leaky = A_Leaky / (VisfL * Kp);

double C_en_tight = en_Tight / (VisfT * Kp_en);
double C_en_leaky = en_Leaky / (VisfL * Kp_en);

double conc_A_rec_I = C_A_rec_I;

double conc_A_rec_D = C_A_rec_D;

double C_en_REC_I = C_en_rec_I;

double FcRn_total_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_total_rec = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;
  

double FcRn_occ_mab_central_serum   = C_FcRn_A_central_serum  / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_endo_central_serum  = C_FcRn_en_central_serum / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_total_central_serum = (C_FcRn_A_central_serum + C_FcRn_en_central_serum) / (FcRn_tot_central_serum + 1e-9);
double FcRn_free_frac_central_serum = C_FcRn_central_serum    / (FcRn_tot_central_serum + 1e-9);

double FcRn_occ_mab_rec   = C_FcRn_A_rec  / (FcRn_tot_rec + 1e-9);
double FcRn_occ_endo_rec  = C_FcRn_en_rec / (FcRn_tot_rec + 1e-9);
double FcRn_occ_total_rec = (C_FcRn_A_rec + C_FcRn_en_rec) / (FcRn_tot_rec + 1e-9);
double FcRn_free_frac_rec = C_FcRn_rec    / (FcRn_tot_rec + 1e-9);

 
double FcRn_mass_balance_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_mass_balance_rec    = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec; 
 

// --- UPDATED overall mucosal concentrations include deep pool
double C_A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1) / Vrec;

double A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1);

// Endo overall unchanged (no deep pool for endo)
double C_en_REC_Overall = (en_rec_blood + C_en_rec_I * g_REC_IV  + (C_en_rec_es + C_FcRn_en_rec)*Ve1) / Vrec;

// Total amounts (mAb): include deep pools for mass balance
double total_mAb_amount =
  A_central_serum +
  A_central_serum_es +
  C_FcRn_A_central_serum * g_VE +
  A_Tight + A_Leaky + A_lymph +
  A_rec_blood +
  A_rec_es +
  C_FcRn_A_rec * g_Ve1 +
  C_A_rec_I * g_REC_IV +
  C_A_rec_D * g_REC_DV;

double total_endo_amount =
  (C_en_central_serum * g_Vcentral_serum) +
  (C_en_central_serum_es * g_VE) +
  (C_FcRn_en_central_serum * g_VE) +
  en_Tight + en_Leaky +
  (C_Ly_en * g_Vlymph) +
  en_rec_blood +
  C_en_rec_I * g_REC_IV +
  C_en_rec_es * g_Ve1 +
  C_FcRn_en_rec * g_Ve1;

double cumulative_mAb_input = 15000;
double mAb_in_body = total_mAb_amount;
double mAb_degraded = A_mAb_degraded;
double mAb_mass_balance = cumulative_mAb_input - (mAb_in_body + mAb_degraded);

$CAPTURE
C_Central_Serum C_Lymph C_A_Tight C_A_Leaky
Conc_en_central_serum C_en_lymph C_en_tight C_en_leaky

C_en_REC_I
conc_A_rec_I
conc_A_rec_D

C_A_rec_Overall
A_rec_Overall

C_en_REC_Overall

FcRn_occ_mab_central_serum FcRn_occ_endo_central_serum FcRn_occ_total_central_serum FcRn_free_frac_central_serum
FcRn_occ_mab_rec FcRn_occ_endo_rec FcRn_occ_total_rec FcRn_free_frac_rec

FcRn_mass_balance_central_serum FcRn_mass_balance_rec

total_mAb_amount total_endo_amount mAb_in_body mAb_degraded
mAb_mass_balance cumulative_mAb_input
"



# =============================================================================
# 3. VRC01LS Female Model
# =============================================================================
 
VRC01LS_MODEL_CODE <- "
$PROB
A minimal PBPK model to predict exposure of VRC01LS with deep/slow mucosal ISF subspaces (rectum/vagina/cervix)

$GLOBAL
double g_Vcentral_serum;
double g_Vlymph;
double g_VE;
double g_Ve1;
double g_Ve2;
double g_Ve3;
double g_REC_IV;
double g_VAG_IV;
double g_CER_IV;

double g_REC_DV;
double g_VAG_DV;
double g_CER_DV;

double total_mAb_initial = -1.0;
double total_endo_initial = -1.0;

$PARAM @annotated
// {Physiological Parameters}
TVVcentral_serum          : 2.6       : Central serum volume (L)
TVVisf             : 15.6      : Interstitial fluid volume (L)
TVVrec             : 0.021     : Rectum tissue volume (L)
TVVvag             : 0.026     : Vagina tissue volume (L)
TVVcer             : 0.0253    : Cervix tissue volume (L)
TVVrec_blood       : 0.0022    : Rectum blood volume (L)
TVVvag_blood       : 0.01      : Vagina blood volume (L)
TVVcer_blood       : 0.009375  : Cervix blood volume (L)
TVQrec             : 8.1504    : Rectum blood flow (L/day)
TVQvag             : 3.6       : Vagina blood flow (L/day)
TVQcer             : 5.78      : Cervix blood flow (L/day)

TVVlymph           : 5.2       : Volume of lymph (L)
TVL                : 2.9       : Total lymph flow (L/day)
TVKp               : 0.8       : Fraction of interstitial space available for antibody distribution
TVKp_en            : 0.8       : Fraction of interstitial space available for Endogenous IgG distribution

TVRfT              : 0.985     : Vascular reflection coefficient for tight tissues
TVRfL              : 0.835     : Vascular reflection coefficient for leaky tissues
TVRflymph          : 0.2       : Lymphatic vascular reflection coefficient for mAb and Endo IgG

// FcRn + Endosome
FcRn_tot_central_serum    : 40000     : Total FcRn concentration in central serum endosome (nM)
FcRn_tot_rec       : 40000     : Total FcRn concentration in rectum endosome (nM)
FcRn_tot_vag       : 40000     : Total FcRn concentration in vagina endosome (nM)
FcRn_tot_cer       : 40000     : Total FcRn concentration in cervix endosome (nM)

TVVe1              : 0.000105  : Endosome volume rectum (L)
TVVe2              : 0.00013   : Endosome volume vagina (L)
TVVe3              : 0.0001265 : Endosome volume cervix (L)
// mAb kinetics
TVkup_A            : 1.0       : mAb central serum uptake rate constant (1/day)
TVkdeg_A           : 10        : mAb central serum degradation rate constant (1/day)
TVkdeg_t_A         : 500       : mAb tissue degradation rate constant (1/day)
krecy_A            : 138.62    : mAb recycling rate constant (1/day), FIXED
TVVE               : 0.31      : Endosome volume for nonspecific pinocytosis (L) for central_serum
TVkon_A            : 18.84     : Antibody FcRn association rate constant (nM-1.day-1) in endosomes
TVkoff_A           : 4821      : Antibody-FcRn complex dissociation rate constant (1/day) in endosomes

// endogenous IgG kinetics
TVkup_en           : 1.0       : Endogenous IgG central serum uptake (1/day), FITTED
TVkdeg_en          : 1.2       : Endogenous IgG central serum degradation (1/day), FITTED
TVkup_t_en         : 149.0     : Endogenous IgG tissue uptake rate constant (1/day)
TVkdeg_t_en        : 388.3     : Endogenous IgG tissue degradation rate constant (1/day)
krecy_en           : 14.088    : Endogenous IgG recycling rate constant (1/day), FIXED
TVkon_en           : 8.12      : Endogenous IgG association rate constant (nM-1.day-1)
TVkoff_en          : 24106     : Endogenous IgG dissociation rate constant (1/day)
TVk0               : 15900     : mean IgG synthesis rate (nmol/day)
TVREC_IV           : 0.00315   : Rectum interstitial volume (L)
TVVAG_IV           : 0.0039    : Vagina interstitial volume (L)
TVCER_IV           : 0.00375   : Cervix interstitial volume (L)

// --- NEW: deep/slow mucosal ISF subspace (mAb only)
TVkdeep_in_rec     : 0.002 : ISF->deep rec (1/day)
TVkdeep_out_rec    : 0.025 : deep->ISF rec (1/day)
TVkdeep_in         : 0.001      : ISF -> deep uptake (1/day) (mAb)
TVkdeep_out        : 0.001     : deep -> ISF return (1/day) (mAb)

TVdeep_frac        : 1     : deep volume fraction of mucosal ISF (unitless)
TVendo_init_fold   : 1         : Fold on direct endogenous baseline initials (unitless)

//  C_ : concentration, without C_ in the beginning is amount
//  A_ : antibody; en_ : endogenous IgG; es: endosome

$CMT @annotated
A_central_serum           : Antibody in central serum (nmol)
A_central_serum_es        : Antibody in central serum endosome (nmol)
C_FcRn_A_central_serum    : FcRn–antibody complex in central serum endosome (nM)
central_serum_auc         : Central serum AUC (nM*day)

A_Tight            : Antibody in tight tissue (nmol)
A_Leaky            : Antibody in leaky tissue (nmol)
A_lymph            : Antibody in lymph (nmol)

A_rec_es           : Antibody in rectum endosome (nmol)
A_vag_es           : Antibody in vagina endosome (nmol)
A_cer_es           : Antibody in cervical endosome (nmol)

A_rec_blood        : Antibody in rectum vascular compartment (nmol)
A_vag_blood        : Antibody in vagina vascular compartment (nmol)
A_cer_blood        : Antibody in cervix vascular compartment (nmol)

C_FcRn_A_rec       : FcRn–antibody complex in rectum endosome (nM)
C_FcRn_A_vag       : FcRn–antibody complex in vagina endosome (nM)
C_FcRn_A_cer       : FcRn–antibody complex in cervix endosome (nM)

C_en_central_serum        : Endogenous IgG in central serum (nM)
C_en_central_serum_es     : Endogenous IgG in central serum endosome (nM)
C_FcRn_en_central_serum   : FcRn–endogenous IgG complex in central serum endosome (nM)

en_Tight           : Endogenous IgG in tight tissue (nmol)
en_Leaky           : Endogenous IgG in leaky tissue (nmol)
C_Ly_en            : Endogenous IgG in lymph (nM)

en_rec_blood       : Endogenous IgG in rectum vascular compartment (nmol)
C_en_rec_es        : Endogenous IgG in rectum endosome (nM)
C_FcRn_en_rec      : FcRn–endogenous IgG complex in rectum endosome (nM)

en_vag_blood       : Endogenous IgG in vagina vascular compartment (nmol)
C_en_vag_es        : Endogenous IgG in vagina endosome (nM)
C_FcRn_en_vag      : FcRn–endogenous IgG complex in vagina endosome (nM)

en_cer_blood       : Endogenous IgG in cervix vascular compartment (nmol)
C_en_cer_es        : Endogenous IgG in cervix endosome (nM)
C_FcRn_en_cer      : FcRn–endogenous IgG complex in cervix endosome (nM)

// mucosal ISF concentrations (nM)
C_A_rec_I          : mAb rectum ISF concentration (nM)
C_A_vag_I          : mAb vagina ISF concentration (nM)
C_A_cer_I          : mAb cervix ISF concentration (nM)

// --- NEW: deep/slow mucosal subspace concentrations (nM)
C_A_rec_D          : mAb rectum deep concentration (nM)
C_A_vag_D          : mAb vagina deep concentration (nM)
C_A_cer_D          : mAb cervix deep concentration (nM)

// endogenous mucosal ISF concentrations (nM)
C_en_rec_I         : Endogenous IgG rectum ISF concentration (nM)
C_en_vag_I         : Endogenous IgG vagina ISF concentration (nM)
C_en_cer_I         : Endogenous IgG cervix ISF concentration (nM)

C_en_rec_D         : Endogenous IgG rectum deep concentration (nM)
C_en_vag_D         : Endogenous IgG vagina deep concentration (nM)
C_en_cer_D         : Endogenous IgG cervix deep concentration (nM)

A_mAb_degraded     : Cumulative amount of mAb degraded (nmol)

$OMEGA
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 

$MAIN

double Vlymph = TVVlymph * exp(ETA(1));
double L   =  TVL  * exp(ETA(2));

double Kp  =  0.8*exp(ETA(3));    
double RfT = TVRfT  * exp(ETA(4));
double RfL =  TVRfL   * exp(ETA(5));
double Rflymph =  TVRflymph   * exp(ETA(6));
double kup_A = TVkup_A * exp(ETA(7));
double kdeg_A = TVkdeg_A * exp(ETA(9));
double kdeg_t_A = TVkdeg_t_A * exp(ETA(10));
 
double kon_A  =  TVkon_A  * exp(ETA(12));
double koff_A = TVkoff_A   * exp(ETA(13));

double Vcentral_serum = TVVcentral_serum * exp(ETA(14));
double Visf = TVVisf * exp(ETA(15));
double VisfT = Visf*0.65;
double VisfL = Visf*0.35;
double LT = L*0.33;
double LL = L*0.67;

double Ve1  = TVVe1  * exp(ETA(11));
double Ve2  = TVVe2  * exp(ETA(16));
double Ve3  = TVVe3  * exp(ETA(17));

double Vrec = TVVrec * exp(ETA(18));
double Vvag = TVVvag * exp(ETA(19));
double Vcer = TVVcer * exp(ETA(20));
double Qrec = TVQrec * exp(ETA(21));
double Qvag = TVQvag * exp(ETA(22));
double Qcer = TVQcer * exp(ETA(23));
double Vrec_blood = TVVrec_blood * exp(ETA(24));
double Vvag_blood = TVVvag_blood * exp(ETA(25));
double Vcer_blood = TVVcer_blood * exp(ETA(26));

double kon_en   =  TVkon_en     * exp(ETA(27));
double koff_en  =  TVkoff_en     * exp(ETA(28));
double kup_en = TVkup_en * exp(ETA(29));
double kdeg_en = TVkdeg_en * exp(ETA(30));
double kup_t_en = TVkup_t_en * exp(ETA(31));
double kdeg_t_en = TVkdeg_t_en * exp(ETA(32));
double k0  =  TVk0 * exp(ETA(33));
double VE  =  TVVE * exp(ETA(34));

double Kp_en= TVKp_en * exp(ETA(35));
double fserum = 0.715;

// Mucosal reflection coefficients and volumes
double REC_VRC = 0.7;
double VAG_VRC = 0.85;
double CER_VRC = 0.85;

double REC_ISRC = 0.2;
double VAG_ISRC = 0.2;
double CER_ISRC = 0.2;

double REC_IV = TVREC_IV;
double VAG_IV = TVVAG_IV;
double CER_IV = TVCER_IV;

double REC_LF = Qrec * 0.002;
double VAG_LF = Qvag * 0.002;
double CER_LF = Qcer * 0.002;

// --- NEW deep volumes (L)
double deep_frac = TVdeep_frac;
double REC_DV = deep_frac * REC_IV;
double VAG_DV = deep_frac * VAG_IV;
double CER_DV = deep_frac * CER_IV;

// --- NEW deep exchange rates
double kdeep_in  = TVkdeep_in;
double kdeep_out = TVkdeep_out;
double kdeep_in_rec  = TVkdeep_in_rec;
double kdeep_out_rec = TVkdeep_out_rec;


// Clearances from rate constants × blood volumes
double CLup_A = kup_A * Vcentral_serum;
double CLup_en = kup_en * Vcentral_serum;

double CLup_rec = kup_A * Vrec_blood;
double CLup_vag = kup_A * Vvag_blood;
double CLup_cer = kup_A * Vcer_blood;

double CLup_en_rec = kup_t_en * Vrec_blood;
double CLup_en_vag = kup_t_en * Vvag_blood;
double CLup_en_cer = kup_t_en * Vcer_blood;

// Direct endogenous baseline init (female) with optional high-IgG fold.
double endo_init_fold = TVendo_init_fold;
C_en_central_serum_0 = 61754;
en_rec_blood_0     = 61848 * Vrec_blood;
en_vag_blood_0     = 61702 * Vvag_blood;
en_cer_blood_0     = 61768 * Vcer_blood;

C_en_central_serum_es_0 = 15075;
C_Ly_en_0 = 13740;

en_Tight_0 = 4246 * (15.6 * 0.65 * 0.8);
en_Leaky_0 = 23389 * (15.6 * 0.35 * 0.8);

C_en_rec_es_0      = 309445;
C_en_vag_es_0      = 1473135;
C_en_cer_es_0      = 1444798;

C_en_rec_I_0       = 11018;
C_en_vag_I_0       = 5550;
C_en_cer_I_0       = 6840;

C_en_rec_D_0       = 0;
C_en_vag_D_0       = 0;
C_en_cer_D_0       = 0;

C_FcRn_en_central_serum_0 = 33415;
if (C_FcRn_en_central_serum_0 > FcRn_tot_central_serum) C_FcRn_en_central_serum_0 = FcRn_tot_central_serum;

C_FcRn_en_rec_0 = 39620;
if (C_FcRn_en_rec_0 > FcRn_tot_rec) C_FcRn_en_rec_0 = FcRn_tot_rec;

C_FcRn_en_vag_0 = 39920;
if (C_FcRn_en_vag_0 > FcRn_tot_vag) C_FcRn_en_vag_0 = FcRn_tot_vag;

C_FcRn_en_cer_0 = 39918;
if (C_FcRn_en_cer_0 > FcRn_tot_cer) C_FcRn_en_cer_0 = FcRn_tot_cer;


// Save globals for TABLE mass-balance
g_Vlymph = Vlymph;
g_Vcentral_serum = Vcentral_serum;
g_VE = VE;
g_Ve1 = Ve1;
g_Ve2 = Ve2;
g_Ve3 = Ve3;
g_REC_IV = REC_IV;
g_VAG_IV = VAG_IV;
g_CER_IV = CER_IV;
g_REC_DV = REC_DV;
g_VAG_DV = VAG_DV;
g_CER_DV = CER_DV;

$ODE

double C_A_rec_blood = A_rec_blood / Vrec_blood;
double C_A_vag_blood = A_vag_blood / Vvag_blood;
double C_A_cer_blood = A_cer_blood / Vcer_blood;

double C_en_rec_blood = en_rec_blood / Vrec_blood;
double C_en_vag_blood = en_vag_blood / Vvag_blood;
double C_en_cer_blood = en_cer_blood / Vcer_blood;

double L_total = L + REC_LF + VAG_LF + CER_LF;

// Free FcRn (nM)
double C_FcRn_central_serum = FcRn_tot_central_serum - C_FcRn_A_central_serum - C_FcRn_en_central_serum;
if(C_FcRn_central_serum < 0.0) C_FcRn_central_serum = 0.0;

double C_FcRn_rec = FcRn_tot_rec - C_FcRn_A_rec - C_FcRn_en_rec;
if(C_FcRn_rec < 0.0) C_FcRn_rec = 0.0;

double C_FcRn_vag = FcRn_tot_vag - C_FcRn_A_vag - C_FcRn_en_vag;
if(C_FcRn_vag < 0.0) C_FcRn_vag = 0.0;

double C_FcRn_cer = FcRn_tot_cer - C_FcRn_A_cer - C_FcRn_en_cer;
if(C_FcRn_cer < 0.0) C_FcRn_cer = 0.0;

// --- Central mAb
dxdt_A_central_serum =
  L_total*A_lymph/Vlymph
  -Qrec*A_central_serum/Vcentral_serum + (Qrec-REC_LF)*A_rec_blood/Vrec_blood
  -Qvag*A_central_serum/Vcentral_serum + (Qvag-VAG_LF)*A_vag_blood/Vvag_blood
  -Qcer*A_central_serum/Vcentral_serum + (Qcer-CER_LF)*A_cer_blood/Vcer_blood
  -(1-RfT)*LT*A_central_serum/Vcentral_serum
  -(1-RfL)*LL*A_central_serum/Vcentral_serum
  -CLup_A*A_central_serum/Vcentral_serum
  +krecy_A*VE*C_FcRn_A_central_serum;

dxdt_A_central_serum_es =
  -kon_A*(A_central_serum_es/VE)*C_FcRn_central_serum*VE
  +koff_A*C_FcRn_A_central_serum*VE
  -kdeg_A*A_central_serum_es
  +CLup_A*A_central_serum/Vcentral_serum;

dxdt_C_FcRn_A_central_serum =
  kon_A*C_FcRn_central_serum*(A_central_serum_es/VE)
  -koff_A*C_FcRn_A_central_serum
  -krecy_A*C_FcRn_A_central_serum;

// --- Central endogenous IgG (central_serum conc nM)
dxdt_C_en_central_serum =
  (1/Vcentral_serum) * (
    k0 + L_total*C_Ly_en
    -Qrec*C_en_central_serum + (Qrec-REC_LF)*en_rec_blood/Vrec_blood
    -Qvag*C_en_central_serum + (Qvag-VAG_LF)*en_vag_blood/Vvag_blood
    -Qcer*C_en_central_serum + (Qcer-CER_LF)*en_cer_blood/Vcer_blood
    -(1-RfT)*LT*C_en_central_serum
    -(1-RfL)*LL*C_en_central_serum
    -CLup_en*C_en_central_serum
    +krecy_en*VE*C_FcRn_en_central_serum
  );

dxdt_C_en_central_serum_es =
  (1/VE) * (
    -kon_en*C_en_central_serum_es*VE*C_FcRn_central_serum
    +koff_en*C_FcRn_en_central_serum*VE
    +CLup_en*C_en_central_serum
    -kdeg_en*C_en_central_serum_es*VE
  );

dxdt_C_FcRn_en_central_serum =
  kon_en*C_FcRn_central_serum*C_en_central_serum_es
  -koff_en*C_FcRn_en_central_serum
  -krecy_en*C_FcRn_en_central_serum;

// --- Tight/leaky lumped tissues (mAb + endo)
dxdt_A_Tight = (1-RfT)*LT*A_central_serum/Vcentral_serum - (1-Rflymph)*LT*A_Tight/(VisfT*Kp);
dxdt_A_Leaky = (1-RfL)*LL*A_central_serum/Vcentral_serum - (1-Rflymph)*LL*A_Leaky/(VisfL*Kp);

dxdt_A_lymph =
  (1-Rflymph)*LT*A_Tight/(VisfT*Kp) +
  (1-Rflymph)*LL*A_Leaky/(VisfL*Kp) +
  (1-REC_ISRC)*REC_LF*C_A_rec_I +
  (1-VAG_ISRC)*VAG_LF*C_A_vag_I +
    (1-CER_ISRC)*CER_LF*C_A_cer_I+
  -L_total*A_lymph/Vlymph;

dxdt_en_Tight = (1-RfT)*LT*C_en_central_serum - (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en);
dxdt_en_Leaky = (1-RfL)*LL*C_en_central_serum - (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en);

dxdt_C_Ly_en =
  (
    (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en) +
    (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en) +
    (1-REC_ISRC)*REC_LF*C_en_rec_I +
    (1-VAG_ISRC)*VAG_LF*C_en_vag_I +
    (1-CER_ISRC)*CER_LF*C_en_cer_I
    -L_total*C_Ly_en
  ) / Vlymph;

// --- Rectum vascular + endosome (mAb)
dxdt_A_rec_blood =
  Qrec*A_central_serum/Vcentral_serum
  -(1-REC_VRC)*REC_LF*(A_rec_blood/Vrec_blood)
  -CLup_rec*A_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*A_rec_blood/Vrec_blood
  +fserum*krecy_A*C_FcRn_A_rec*Ve1;

dxdt_A_rec_es =
  -kon_A*(A_rec_es/Ve1)*C_FcRn_rec*Ve1
  +koff_A*C_FcRn_A_rec*Ve1
  -kdeg_t_A*A_rec_es
  +CLup_rec*C_A_rec_I
  +CLup_rec*A_rec_blood/Vrec_blood;

dxdt_C_FcRn_A_rec =
  kon_A*C_FcRn_rec*(A_rec_es/Ve1)
  -koff_A*C_FcRn_A_rec
  -krecy_A*C_FcRn_A_rec;

// --- Rectum vascular + endosome (endo)
dxdt_en_rec_blood =
  Qrec*C_en_central_serum
  -(1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood)
  -CLup_en_rec*en_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*en_rec_blood/Vrec_blood
  +fserum*krecy_en*C_FcRn_en_rec*Ve1;

dxdt_C_en_rec_es =
  (1/Ve1) * (
    -kon_en*C_en_rec_es*Ve1*C_FcRn_rec
    +koff_en*C_FcRn_en_rec*Ve1
    +CLup_en_rec*(en_rec_blood/Vrec_blood)
    +CLup_en_rec*C_en_rec_I
    -kdeg_t_en*C_en_rec_es*Ve1
  );

dxdt_C_FcRn_en_rec =
  kon_en*C_FcRn_rec*C_en_rec_es
  -koff_en*C_FcRn_en_rec
  -krecy_en*C_FcRn_en_rec;

// --- Vagina vascular + endosome (mAb)
dxdt_A_vag_blood =
  Qvag*A_central_serum/Vcentral_serum
  -(1-VAG_VRC)*VAG_LF*(A_vag_blood/Vvag_blood)
  -CLup_vag*A_vag_blood/Vvag_blood
  -(Qvag-VAG_LF)*A_vag_blood/Vvag_blood
  +fserum*krecy_A*C_FcRn_A_vag*Ve2;

dxdt_A_vag_es =
  -kon_A*(A_vag_es/Ve2)*C_FcRn_vag*Ve2
  +koff_A*C_FcRn_A_vag*Ve2
  -kdeg_t_A*A_vag_es
  +CLup_vag*C_A_vag_I
  +CLup_vag*A_vag_blood/Vvag_blood;

dxdt_C_FcRn_A_vag =
  kon_A*C_FcRn_vag*(A_vag_es/Ve2)
  -koff_A*C_FcRn_A_vag
  -krecy_A*C_FcRn_A_vag;

// --- Vagina vascular + endosome (endo)
dxdt_en_vag_blood =
  Qvag*C_en_central_serum
  -(1-VAG_VRC)*VAG_LF*(en_vag_blood/Vvag_blood)
  -CLup_en_vag*en_vag_blood/Vvag_blood
  -(Qvag-VAG_LF)*en_vag_blood/Vvag_blood
  +fserum*krecy_en*C_FcRn_en_vag*Ve2;

dxdt_C_en_vag_es =
  (1/Ve2) * (
    -kon_en*C_en_vag_es*Ve2*C_FcRn_vag
    +koff_en*C_FcRn_en_vag*Ve2
    +CLup_en_vag*(en_vag_blood/Vvag_blood)
    +CLup_en_vag*C_en_vag_I
    -kdeg_t_en*C_en_vag_es*Ve2
  );

dxdt_C_FcRn_en_vag =
  kon_en*C_FcRn_vag*C_en_vag_es
  -koff_en*C_FcRn_en_vag
  -krecy_en*C_FcRn_en_vag;

// --- Cervix vascular + endosome (mAb)
dxdt_A_cer_blood =
  Qcer*A_central_serum/Vcentral_serum
  -(1-CER_VRC)*CER_LF*(A_cer_blood/Vcer_blood)
  -CLup_cer*A_cer_blood/Vcer_blood
  -(Qcer-CER_LF)*A_cer_blood/Vcer_blood
  +fserum*krecy_A*C_FcRn_A_cer*Ve3;

dxdt_A_cer_es =
  -kon_A*(A_cer_es/Ve3)*C_FcRn_cer*Ve3
  +koff_A*C_FcRn_A_cer*Ve3
  -kdeg_t_A*A_cer_es
  +CLup_cer*C_A_cer_I
  +CLup_cer*A_cer_blood/Vcer_blood;

dxdt_C_FcRn_A_cer =
  kon_A*C_FcRn_cer*(A_cer_es/Ve3)
  -koff_A*C_FcRn_A_cer
  -krecy_A*C_FcRn_A_cer;

// --- Cervix vascular + endosome (endo)
dxdt_en_cer_blood =
  Qcer*C_en_central_serum
  -(1-CER_VRC)*CER_LF*(en_cer_blood/Vcer_blood)
  -CLup_en_cer*en_cer_blood/Vcer_blood
  -(Qcer-CER_LF)*en_cer_blood/Vcer_blood
  +fserum*krecy_en*C_FcRn_en_cer*Ve3;

dxdt_C_en_cer_es =
  (1/Ve3) * (
    -kon_en*C_en_cer_es*Ve3*C_FcRn_cer
    +koff_en*C_FcRn_en_cer*Ve3
    +CLup_en_cer*(en_cer_blood/Vcer_blood)
    +CLup_en_cer*C_en_cer_I
    -kdeg_t_en*C_en_cer_es*Ve3
  );

dxdt_C_FcRn_en_cer =
  kon_en*C_FcRn_cer*C_en_cer_es
  -koff_en*C_FcRn_en_cer
  -krecy_en*C_FcRn_en_cer;

// --- MUCOSAL ISF (mAb): with deep/slow subspace exchange
dxdt_C_A_rec_I =
  (((1 - REC_VRC) * REC_LF * C_A_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_A_rec_I) / REC_IV)
  - ((CLup_rec * C_A_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_A_rec_I
  + kdeep_out_rec * C_A_rec_D;

dxdt_C_A_vag_I =
  (((1 - VAG_VRC) * VAG_LF * C_A_vag_blood) / VAG_IV)
  - (((1 - VAG_ISRC) * VAG_LF * C_A_vag_I) / VAG_IV)
  - ((CLup_vag * C_A_vag_I) / VAG_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_vag * (Ve2 / VAG_IV))
  // deep exchange
  - kdeep_in * C_A_vag_I
  + kdeep_out * C_A_vag_D;

dxdt_C_A_cer_I =
  (((1 - CER_VRC) * CER_LF * C_A_cer_blood) / CER_IV)
  - (((1 - CER_ISRC) * CER_LF * C_A_cer_I) / CER_IV)
  - ((CLup_cer * C_A_cer_I) / CER_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_cer * (Ve3 / CER_IV))
  // deep exchange
  - kdeep_in * C_A_cer_I
  + kdeep_out * C_A_cer_D;

// --- NEW: deep compartments (mAb): mass-balanced via IV/DV scaling
dxdt_C_A_rec_D =
  kdeep_in_rec * C_A_rec_I  
  - kdeep_out_rec * C_A_rec_D;

dxdt_C_A_vag_D =
  kdeep_in * C_A_vag_I  
  - kdeep_out * C_A_vag_D;

dxdt_C_A_cer_D =
  kdeep_in * C_A_cer_I  
  - kdeep_out * C_A_cer_D;

// --- MUCOSAL ISF (endo) unchanged
dxdt_C_en_rec_I =
  (((1 - REC_VRC) * REC_LF * C_en_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_en_rec_I) / REC_IV)
  - ((CLup_en_rec * C_en_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_en_rec_I;

dxdt_C_en_vag_I =
  (((1 - VAG_VRC) * VAG_LF * C_en_vag_blood) / VAG_IV)
  - (((1 - VAG_ISRC) * VAG_LF * C_en_vag_I) / VAG_IV)
  - ((CLup_en_vag * C_en_vag_I) / VAG_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_vag * (Ve2 / VAG_IV))
  // deep exchange
  - kdeep_in * C_en_vag_I;

dxdt_C_en_cer_I =
  (((1 - CER_VRC) * CER_LF * C_en_cer_blood) / CER_IV)
  - (((1 - CER_ISRC) * CER_LF * C_en_cer_I) / CER_IV)
  - ((CLup_en_cer * C_en_cer_I) / CER_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_cer * (Ve3 / CER_IV))
  // deep exchange
  - kdeep_in * C_en_cer_I;

// --- NEW: deep compartments (endogenous IgG)
dxdt_C_en_rec_D =0;

dxdt_C_en_vag_D =0;

dxdt_C_en_cer_D =0;


// Track cumulative mAb degradation
dxdt_A_mAb_degraded =
  kdeg_A*A_central_serum_es +
  kdeg_t_A*A_rec_es +
  kdeg_t_A*A_vag_es +
  kdeg_t_A*A_cer_es;

// AUC
dxdt_central_serum_auc = A_central_serum/Vcentral_serum;

$TABLE
double C_Central_Serum = (A_central_serum) / Vcentral_serum;
double C_Lymph  = A_lymph / Vlymph;

double Conc_en_central_serum = C_en_central_serum;
double C_en_lymph = C_Ly_en;

double C_A_Tight = A_Tight / (VisfT * Kp);
double C_A_Leaky = A_Leaky / (VisfL * Kp);

double C_en_tight = en_Tight / (VisfT * Kp_en);
double C_en_leaky = en_Leaky / (VisfL * Kp_en);

double conc_A_rec_I = C_A_rec_I;
double conc_A_vag_I = C_A_vag_I;
double conc_A_cer_I = C_A_cer_I;

double conc_A_rec_D = C_A_rec_D;
double conc_A_vag_D = C_A_vag_D;
double conc_A_cer_D = C_A_cer_D;

double C_en_REC_I = C_en_rec_I;
double C_en_VAG_I = C_en_vag_I;
double C_en_CER_I = C_en_cer_I;

double FcRn_total_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_total_rec = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;
double FcRn_total_vag = C_FcRn_vag + C_FcRn_A_vag + C_FcRn_en_vag;
double FcRn_total_cer = C_FcRn_cer + C_FcRn_A_cer + C_FcRn_en_cer;

double FcRn_occ_mab_central_serum   = C_FcRn_A_central_serum  / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_endo_central_serum  = C_FcRn_en_central_serum / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_total_central_serum = (C_FcRn_A_central_serum + C_FcRn_en_central_serum) / (FcRn_tot_central_serum + 1e-9);
double FcRn_free_frac_central_serum = C_FcRn_central_serum    / (FcRn_tot_central_serum + 1e-9);

double FcRn_occ_mab_rec   = C_FcRn_A_rec  / (FcRn_tot_rec + 1e-9);
double FcRn_occ_endo_rec  = C_FcRn_en_rec / (FcRn_tot_rec + 1e-9);
double FcRn_occ_total_rec = (C_FcRn_A_rec + C_FcRn_en_rec) / (FcRn_tot_rec + 1e-9);
double FcRn_free_frac_rec = C_FcRn_rec    / (FcRn_tot_rec + 1e-9);

double FcRn_occ_mab_vag   = C_FcRn_A_vag  / (FcRn_tot_vag + 1e-9);
double FcRn_occ_endo_vag  = C_FcRn_en_vag / (FcRn_tot_vag + 1e-9);
double FcRn_occ_total_vag = (C_FcRn_A_vag + C_FcRn_en_vag) / (FcRn_tot_vag + 1e-9);
double FcRn_free_frac_vag = C_FcRn_vag    / (FcRn_tot_vag + 1e-9);

double FcRn_occ_mab_cer   = C_FcRn_A_cer  / (FcRn_tot_cer + 1e-9);
double FcRn_occ_endo_cer  = C_FcRn_en_cer / (FcRn_tot_cer + 1e-9);
double FcRn_occ_total_cer = (C_FcRn_A_cer + C_FcRn_en_cer) / (FcRn_tot_cer + 1e-9);
double FcRn_free_frac_cer = C_FcRn_cer    / (FcRn_tot_cer + 1e-9);

double FcRn_mass_balance_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_mass_balance_rec    = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;
double FcRn_mass_balance_vag    = C_FcRn_vag + C_FcRn_A_vag + C_FcRn_en_vag;
double FcRn_mass_balance_cer    = C_FcRn_cer + C_FcRn_A_cer + C_FcRn_en_cer;

 

// --- UPDATED overall mucosal concentrations include deep pool
double C_A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1) / Vrec;

double C_A_vag_Overall =
  (A_vag_blood + C_A_vag_I * g_VAG_IV + C_A_vag_D * g_VAG_DV + A_vag_es + C_FcRn_A_vag*Ve2) / Vvag;

double C_A_cer_Overall =
  (A_cer_blood + C_A_cer_I * g_CER_IV + C_A_cer_D * g_CER_DV + A_cer_es + C_FcRn_A_cer*Ve3) / Vcer;

double A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1);

double A_vag_Overall =
  (A_vag_blood + C_A_vag_I * g_VAG_IV + C_A_vag_D * g_VAG_DV + A_vag_es + C_FcRn_A_vag*Ve2);

double A_cer_Overall =
  (A_cer_blood + C_A_cer_I * g_CER_IV + C_A_cer_D * g_CER_DV + A_cer_es + C_FcRn_A_cer*Ve3);

// Endo overall unchanged (no deep pool for endo)
double C_en_REC_Overall = (en_rec_blood + C_en_rec_I * g_REC_IV  + (C_en_rec_es + C_FcRn_en_rec)*Ve1) / Vrec;
double C_en_VAG_Overall = (en_vag_blood + C_en_vag_I * g_VAG_IV  + (C_en_vag_es + C_FcRn_en_vag)*Ve2) / Vvag;
double C_en_CER_Overall = (en_cer_blood + C_en_cer_I * g_CER_IV  + (C_en_cer_es + C_FcRn_en_cer)*Ve3) / Vcer;

// Total amounts (mAb): include deep pools for mass balance
double total_mAb_amount =
  A_central_serum +
  A_central_serum_es +
  C_FcRn_A_central_serum * g_VE +
  A_Tight + A_Leaky + A_lymph +
  A_rec_blood + A_vag_blood + A_cer_blood +
  A_rec_es + A_vag_es + A_cer_es +
  C_FcRn_A_rec * g_Ve1 + C_FcRn_A_vag * g_Ve2 + C_FcRn_A_cer * g_Ve3 +
  C_A_rec_I * g_REC_IV + C_A_vag_I * g_VAG_IV + C_A_cer_I * g_CER_IV +
  C_A_rec_D * g_REC_DV + C_A_vag_D * g_VAG_DV + C_A_cer_D * g_CER_DV;

double total_endo_amount =
  (C_en_central_serum * g_Vcentral_serum) +
  (C_en_central_serum_es * g_VE) +
  (C_FcRn_en_central_serum * g_VE) +
  en_Tight + en_Leaky +
  (C_Ly_en * g_Vlymph) +
  en_rec_blood + en_vag_blood + en_cer_blood +
  C_en_rec_I * g_REC_IV + C_en_vag_I * g_VAG_IV + C_en_cer_I * g_CER_IV +
  C_en_rec_es * g_Ve1 + C_en_vag_es * g_Ve2 + C_en_cer_es * g_Ve3 +
  C_FcRn_en_rec * g_Ve1 + C_FcRn_en_vag * g_Ve2 + C_FcRn_en_cer * g_Ve3;

double cumulative_mAb_input = 15000;
double mAb_in_body = total_mAb_amount;
double mAb_degraded = A_mAb_degraded;
double mAb_mass_balance = cumulative_mAb_input - (mAb_in_body + mAb_degraded);

$CAPTURE
C_Central_Serum C_Lymph C_A_Tight C_A_Leaky
Conc_en_central_serum C_en_lymph C_en_tight C_en_leaky

C_en_REC_I C_en_VAG_I C_en_CER_I
conc_A_rec_I conc_A_vag_I conc_A_cer_I
conc_A_rec_D conc_A_vag_D conc_A_cer_D

C_A_rec_Overall C_A_vag_Overall C_A_cer_Overall
A_rec_Overall A_vag_Overall A_cer_Overall

C_en_REC_Overall C_en_VAG_Overall C_en_CER_Overall

FcRn_occ_mab_central_serum FcRn_occ_endo_central_serum FcRn_occ_total_central_serum FcRn_free_frac_central_serum
FcRn_occ_mab_rec FcRn_occ_endo_rec FcRn_occ_total_rec FcRn_free_frac_rec
FcRn_occ_mab_vag FcRn_occ_endo_vag FcRn_occ_total_vag FcRn_free_frac_vag
FcRn_occ_mab_cer FcRn_occ_endo_cer FcRn_occ_total_cer FcRn_free_frac_cer

FcRn_mass_balance_central_serum FcRn_mass_balance_rec FcRn_mass_balance_vag FcRn_mass_balance_cer

total_mAb_amount total_endo_amount mAb_in_body mAb_degraded
mAb_mass_balance cumulative_mAb_input
"





# =============================================================================
# 4. VRC01LS Male Model
# =============================================================================

# ===========================================================
# Same as VRC01LS female but WITHOUT vagina/cervix
# ===========================================================
VRC01LS_MALE_MODEL_CODE <- "

$PROB
A minimal PBPK model to predict exposure of VRC01LS with deep/slow mucosal ISF subspaces (rectum only (male model))

$GLOBAL
double g_Vcentral_serum;
double g_Vlymph;
double g_VE;
double g_Ve1;
 
double g_REC_IV;

double g_REC_DV;

double total_mAb_initial = -1.0;
double total_endo_initial = -1.0;

$PARAM @annotated
// {Physiological Parameters}
TVVcentral_serum          : 2.6       : Central serum volume (L)
TVVisf             : 15.6      : Interstitial fluid volume (L)
TVVrec             : 0.021     : Rectum tissue volume (L)
TVVrec_blood       : 0.0022    : Rectum blood volume (L)
TVQrec             : 8.1504    : Rectum blood flow (L/day)

TVVlymph           : 5.2       : Volume of lymph (L)
TVL                : 2.9       : Total lymph flow (L/day)
TVKp               : 0.8       : Fraction of interstitial space available for antibody distribution
TVKp_en            : 0.8       : Fraction of interstitial space available for Endogenous IgG distribution

TVRfT              : 0.985     : Vascular reflection coefficient for tight tissues
TVRfL              : 0.835     : Vascular reflection coefficient for leaky tissues
TVRflymph          : 0.2       : Lymphatic vascular reflection coefficient for mAb and Endo IgG

// FcRn + Endosome
FcRn_tot_central_serum    : 40000     : Total FcRn concentration in central serum endosome (nM)
FcRn_tot_rec       : 40000     : Total FcRn concentration in rectum endosome (nM)

TVVe1              : 0.000105  : Endosome volume rectum (L)

// mAb kinetics
TVkup_A            : 1.0       : mAb central serum uptake rate constant (1/day)
TVkdeg_A           : 10        : mAb central serum degradation rate constant (1/day)
TVkdeg_t_A         : 500       : mAb tissue degradation rate constant (1/day)
krecy_A            : 138.62    : mAb recycling rate constant (1/day), FIXED
TVVE               : 0.31      : Endosome volume for nonspecific pinocytosis (L) for central_serum
TVkon_A            : 18.84     : Antibody FcRn association rate constant (nM-1.day-1) in endosomes
TVkoff_A           : 4821      : Antibody-FcRn complex dissociation rate constant (1/day) in endosomes

// endogenous IgG kinetics
TVkup_en           : 1.0       : Endogenous IgG central serum uptake (1/day), FITTED
TVkdeg_en          : 1.2       : Endogenous IgG central serum degradation (1/day), FITTED
TVkup_t_en         : 149.0     : Endogenous IgG tissue uptake rate constant (1/day)
TVkdeg_t_en        : 388.3     : Endogenous IgG tissue degradation rate constant (1/day)
krecy_en           : 14.088    : Endogenous IgG recycling rate constant (1/day), FIXED
TVkon_en           : 8.12      : Endogenous IgG association rate constant (nM-1.day-1)
TVkoff_en          : 24106     : Endogenous IgG dissociation rate constant (1/day)
TVk0               : 15900     : mean IgG synthesis rate (nmol/day)
TVREC_IV           : 0.00315   : Rectum interstitial volume (L)
 

// --- NEW: deep/slow mucosal ISF subspace (mAb only)
TVkdeep_in_rec     : 0.002 : ISF->deep rec (1/day)
TVkdeep_out_rec    : 0.025 : deep->ISF rec (1/day)
TVkdeep_in         : 0.001      : ISF -> deep uptake (1/day) (mAb)
TVkdeep_out        : 0.001     : deep -> ISF return (1/day) (mAb)
TVdeep_frac        : 1     : deep volume fraction of mucosal ISF (unitless)
TVendo_init_fold   : 1         : Fold on direct endogenous baseline initials (unitless)

//  C_ : concentration, without C_ in the beginning is amount
//  A_ : antibody; en_ : endogenous IgG; es: endosome

$CMT @annotated
A_central_serum           : Antibody in central serum (nmol)
A_central_serum_es        : Antibody in central serum endosome (nmol)
C_FcRn_A_central_serum    : FcRn–antibody complex in central serum endosome (nM)
central_serum_auc         : Central serum AUC (nM*day)

A_Tight            : Antibody in tight tissue (nmol)
A_Leaky            : Antibody in leaky tissue (nmol)
A_lymph            : Antibody in lymph (nmol)

A_rec_es           : Antibody in rectum endosome (nmol)

A_rec_blood        : Antibody in rectum vascular compartment (nmol)

C_FcRn_A_rec       : FcRn–antibody complex in rectum endosome (nM)

C_en_central_serum        : Endogenous IgG in central serum (nM)
C_en_central_serum_es     : Endogenous IgG in central serum endosome (nM)
C_FcRn_en_central_serum   : FcRn–endogenous IgG complex in central serum endosome (nM)

en_Tight           : Endogenous IgG in tight tissue (nmol)
en_Leaky           : Endogenous IgG in leaky tissue (nmol)
C_Ly_en            : Endogenous IgG in lymph (nM)

en_rec_blood       : Endogenous IgG in rectum vascular compartment (nmol)
C_en_rec_es        : Endogenous IgG in rectum endosome (nM)
C_FcRn_en_rec      : FcRn–endogenous IgG complex in rectum endosome (nM)

// mucosal ISF concentrations (nM)
C_A_rec_I          : mAb rectum ISF concentration (nM)

// --- NEW: deep/slow mucosal subspace concentrations (nM)
C_A_rec_D          : mAb rectum deep concentration (nM)

// endogenous mucosal ISF concentrations (nM)
C_en_rec_I         : Endogenous IgG rectum ISF concentration (nM)

C_en_rec_D         : Endogenous IgG rectum deep concentration (nM)

A_mAb_degraded     : Cumulative amount of mAb degraded (nmol)

$OMEGA
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 

$MAIN

double Vlymph = TVVlymph * exp(ETA(1));
double L   =  TVL  * exp(ETA(2));

double Kp  =  0.8*exp(ETA(3));    
double RfT = TVRfT  * exp(ETA(4));
double RfL =  TVRfL   * exp(ETA(5));
double Rflymph =  TVRflymph   * exp(ETA(6));
double kup_A = TVkup_A * exp(ETA(7));
double kdeg_A = TVkdeg_A * exp(ETA(9));
double kdeg_t_A = TVkdeg_t_A * exp(ETA(10));
double Ve1  = TVVe1  * exp(ETA(11));
double kon_A  =  TVkon_A  * exp(ETA(12));
double koff_A = TVkoff_A   * exp(ETA(13));

double Vcentral_serum = TVVcentral_serum * exp(ETA(14));
double Visf = TVVisf * exp(ETA(15));
double VisfT = Visf*0.65;
double VisfL = Visf*0.35;
double LT = L*0.33;
double LL = L*0.67;

 
double Vrec = TVVrec * exp(ETA(18));
double Qrec = TVQrec * exp(ETA(21));
double Vrec_blood = TVVrec_blood * exp(ETA(24));

double kon_en   =  TVkon_en     * exp(ETA(27));
double koff_en  =  TVkoff_en     * exp(ETA(28));
double kup_en = TVkup_en * exp(ETA(29));
double kdeg_en = TVkdeg_en * exp(ETA(30));
double kup_t_en = TVkup_t_en * exp(ETA(31));
double kdeg_t_en = TVkdeg_t_en * exp(ETA(32));
double k0  =  TVk0 * exp(ETA(33));
double VE  =  TVVE * exp(ETA(34));

double Kp_en= TVKp_en * exp(ETA(35));
double fserum = 0.715;

// Mucosal reflection coefficients and volumes
double REC_VRC = 0.7;

double REC_ISRC = 0.2;

double REC_IV = TVREC_IV;

double REC_LF = Qrec * 0.002;

// --- NEW deep volumes (L)
double deep_frac = TVdeep_frac;
double REC_DV = deep_frac * REC_IV;

// --- NEW deep exchange rates
double kdeep_in  = TVkdeep_in;
double kdeep_out = TVkdeep_out;
double kdeep_in_rec  = TVkdeep_in_rec;
double kdeep_out_rec = TVkdeep_out_rec;


// Clearances from rate constants × blood volumes
double CLup_A = kup_A * Vcentral_serum;
double CLup_en = kup_en * Vcentral_serum;

double CLup_rec = kup_A * Vrec_blood;

double CLup_en_rec = kup_t_en * Vrec_blood;

// Direct endogenous baseline init (male) with optional high-IgG fold.
double endo_init_fold = TVendo_init_fold;
C_en_central_serum_0 = 62896;
en_rec_blood_0 = 62991 * Vrec_blood;

C_en_central_serum_es_0 = 16279;
C_Ly_en_0 = 13960;

en_Tight_0 = 4324 * (15.6 * 0.65 * 0.8);
en_Leaky_0 = 23822 * (15.6 * 0.35 * 0.8);

C_en_rec_es_0 = 318280;

C_en_rec_I_0 = 11202;

C_en_rec_D_0 = 0;

C_FcRn_en_central_serum_0 = 33827;
if (C_FcRn_en_central_serum_0 > FcRn_tot_central_serum) C_FcRn_en_central_serum_0 = FcRn_tot_central_serum;

C_FcRn_en_rec_0 = 39630;
if (C_FcRn_en_rec_0 > FcRn_tot_rec) C_FcRn_en_rec_0 = FcRn_tot_rec;

// Save globals for TABLE mass-balance
g_Vlymph = Vlymph;
g_Vcentral_serum = Vcentral_serum;
g_VE = VE;
g_Ve1 = Ve1;
 
g_REC_IV = REC_IV;
g_REC_DV = REC_DV;

$ODE

double C_A_rec_blood = A_rec_blood / Vrec_blood;

double C_en_rec_blood = en_rec_blood / Vrec_blood;

double L_total = L + REC_LF;

// Free FcRn (nM)
double C_FcRn_central_serum = FcRn_tot_central_serum - C_FcRn_A_central_serum - C_FcRn_en_central_serum;
if(C_FcRn_central_serum < 0.0) C_FcRn_central_serum = 0.0;

double C_FcRn_rec = FcRn_tot_rec - C_FcRn_A_rec - C_FcRn_en_rec;
if(C_FcRn_rec < 0.0) C_FcRn_rec = 0.0;



// --- Central mAb
dxdt_A_central_serum =
  L_total*A_lymph/Vlymph
  -Qrec*A_central_serum/Vcentral_serum + (Qrec-REC_LF)*A_rec_blood/Vrec_blood
  -(1-RfT)*LT*A_central_serum/Vcentral_serum
  -(1-RfL)*LL*A_central_serum/Vcentral_serum
  -CLup_A*A_central_serum/Vcentral_serum
  +krecy_A*VE*C_FcRn_A_central_serum;

dxdt_A_central_serum_es =
  -kon_A*(A_central_serum_es/VE)*C_FcRn_central_serum*VE
  +koff_A*C_FcRn_A_central_serum*VE
  -kdeg_A*A_central_serum_es
  +CLup_A*A_central_serum/Vcentral_serum;

dxdt_C_FcRn_A_central_serum =
  kon_A*C_FcRn_central_serum*(A_central_serum_es/VE)
  -koff_A*C_FcRn_A_central_serum
  -krecy_A*C_FcRn_A_central_serum;

// --- Central endogenous IgG (central_serum conc nM)
dxdt_C_en_central_serum =
  (1/Vcentral_serum) * (
    k0 + L_total*C_Ly_en
    -Qrec*C_en_central_serum + (Qrec-REC_LF)*en_rec_blood/Vrec_blood
    -(1-RfT)*LT*C_en_central_serum
    -(1-RfL)*LL*C_en_central_serum
    -CLup_en*C_en_central_serum
    +krecy_en*VE*C_FcRn_en_central_serum
  );

dxdt_C_en_central_serum_es =
  (1/VE) * (
    -kon_en*C_en_central_serum_es*VE*C_FcRn_central_serum
    +koff_en*C_FcRn_en_central_serum*VE
    +CLup_en*C_en_central_serum
    -kdeg_en*C_en_central_serum_es*VE
  );

dxdt_C_FcRn_en_central_serum =
  kon_en*C_FcRn_central_serum*C_en_central_serum_es
  -koff_en*C_FcRn_en_central_serum
  -krecy_en*C_FcRn_en_central_serum;

// --- Tight/leaky lumped tissues (mAb + endo)
dxdt_A_Tight = (1-RfT)*LT*A_central_serum/Vcentral_serum - (1-Rflymph)*LT*A_Tight/(VisfT*Kp);
dxdt_A_Leaky = (1-RfL)*LL*A_central_serum/Vcentral_serum - (1-Rflymph)*LL*A_Leaky/(VisfL*Kp);

dxdt_A_lymph =
  (1-Rflymph)*LT*A_Tight/(VisfT*Kp) +
  (1-Rflymph)*LL*A_Leaky/(VisfL*Kp) +
  (1-REC_ISRC)*REC_LF*C_A_rec_I +
  -L_total*A_lymph/Vlymph;

dxdt_en_Tight = (1-RfT)*LT*C_en_central_serum - (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en);
dxdt_en_Leaky = (1-RfL)*LL*C_en_central_serum - (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en);

dxdt_C_Ly_en =
  (
    (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en) +
    (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en) +
    (1-REC_ISRC)*REC_LF*C_en_rec_I +
    -L_total*C_Ly_en
  ) / Vlymph;

// --- Rectum vascular + endosome (mAb)
dxdt_A_rec_blood =
  Qrec*A_central_serum/Vcentral_serum
  -(1-REC_VRC)*REC_LF*(A_rec_blood/Vrec_blood)
  -CLup_rec*A_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*A_rec_blood/Vrec_blood
  +fserum*krecy_A*C_FcRn_A_rec*Ve1;

dxdt_A_rec_es =
  -kon_A*(A_rec_es/Ve1)*C_FcRn_rec*Ve1
  +koff_A*C_FcRn_A_rec*Ve1
  -kdeg_t_A*A_rec_es
  +CLup_rec*C_A_rec_I
  +CLup_rec*A_rec_blood/Vrec_blood;

dxdt_C_FcRn_A_rec =
  kon_A*C_FcRn_rec*(A_rec_es/Ve1)
  -koff_A*C_FcRn_A_rec
  -krecy_A*C_FcRn_A_rec;

// --- Rectum vascular + endosome (endo)
dxdt_en_rec_blood =
  Qrec*C_en_central_serum
  -(1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood)
  -CLup_en_rec*en_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*en_rec_blood/Vrec_blood
  +fserum*krecy_en*C_FcRn_en_rec*Ve1;

dxdt_C_en_rec_es =
  (1/Ve1) * (
    -kon_en*C_en_rec_es*Ve1*C_FcRn_rec
    +koff_en*C_FcRn_en_rec*Ve1
    +CLup_en_rec*(en_rec_blood/Vrec_blood)
    +CLup_en_rec*C_en_rec_I
    -kdeg_t_en*C_en_rec_es*Ve1
  );

dxdt_C_FcRn_en_rec =
  kon_en*C_FcRn_rec*C_en_rec_es
  -koff_en*C_FcRn_en_rec
  -krecy_en*C_FcRn_en_rec;





// --- MUCOSAL ISF (mAb): with deep/slow subspace exchange
dxdt_C_A_rec_I =
  (((1 - REC_VRC) * REC_LF * C_A_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_A_rec_I) / REC_IV)
  - ((CLup_rec * C_A_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_A * C_FcRn_A_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_A_rec_I
  + kdeep_out_rec * C_A_rec_D;

// --- NEW: deep compartments (mAb): mass-balanced via IV/DV scaling
dxdt_C_A_rec_D =
  kdeep_in_rec * C_A_rec_I * (REC_IV / REC_DV)
  - kdeep_out_rec * C_A_rec_D;

// --- MUCOSAL ISF (endo) unchanged
dxdt_C_en_rec_I =
  (((1 - REC_VRC) * REC_LF * C_en_rec_blood) / REC_IV)
  - (((1 - REC_ISRC) * REC_LF * C_en_rec_I) / REC_IV)
  - ((CLup_en_rec * C_en_rec_I) / REC_IV)
  + ((1 - fserum) * krecy_en * C_FcRn_en_rec * (Ve1 / REC_IV))
  // deep exchange
  - kdeep_in_rec * C_en_rec_I;

// --- NEW: deep compartments (endogenous IgG)
dxdt_C_en_rec_D =0;

// Track cumulative mAb degradation
dxdt_A_mAb_degraded =
  kdeg_A*A_central_serum_es +
  kdeg_t_A*A_rec_es;

// AUC
dxdt_central_serum_auc = A_central_serum/Vcentral_serum;

$TABLE
double C_Central_Serum = (A_central_serum) / Vcentral_serum;
double C_Lymph  = A_lymph / Vlymph;

double Conc_en_central_serum = C_en_central_serum;
double C_en_lymph = C_Ly_en;

double C_A_Tight = A_Tight / (VisfT * Kp);
double C_A_Leaky = A_Leaky / (VisfL * Kp);

double C_en_tight = en_Tight / (VisfT * Kp_en);
double C_en_leaky = en_Leaky / (VisfL * Kp_en);

double conc_A_rec_I = C_A_rec_I;

double conc_A_rec_D = C_A_rec_D;

double C_en_REC_I = C_en_rec_I;

double FcRn_total_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_total_rec = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;
  
double FcRn_occ_mab_central_serum   = C_FcRn_A_central_serum  / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_endo_central_serum  = C_FcRn_en_central_serum / (FcRn_tot_central_serum + 1e-9);
double FcRn_occ_total_central_serum = (C_FcRn_A_central_serum + C_FcRn_en_central_serum) / (FcRn_tot_central_serum + 1e-9);
double FcRn_free_frac_central_serum = C_FcRn_central_serum    / (FcRn_tot_central_serum + 1e-9);

double FcRn_occ_mab_rec   = C_FcRn_A_rec  / (FcRn_tot_rec + 1e-9);
double FcRn_occ_endo_rec  = C_FcRn_en_rec / (FcRn_tot_rec + 1e-9);
double FcRn_occ_total_rec = (C_FcRn_A_rec + C_FcRn_en_rec) / (FcRn_tot_rec + 1e-9);
double FcRn_free_frac_rec = C_FcRn_rec    / (FcRn_tot_rec + 1e-9);
 
double FcRn_mass_balance_central_serum = C_FcRn_central_serum + C_FcRn_A_central_serum + C_FcRn_en_central_serum;
double FcRn_mass_balance_rec    = C_FcRn_rec + C_FcRn_A_rec + C_FcRn_en_rec;  

// --- UPDATED overall mucosal concentrations include deep pool
double C_A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1) / Vrec;

double A_rec_Overall =
  (A_rec_blood + C_A_rec_I * g_REC_IV + C_A_rec_D * g_REC_DV + A_rec_es + C_FcRn_A_rec*Ve1);

// Endo overall unchanged (no deep pool for endo)
double C_en_REC_Overall = (en_rec_blood + C_en_rec_I * g_REC_IV + (C_en_rec_es + C_FcRn_en_rec)*Ve1) / Vrec;

// Total amounts (mAb): include deep pools for mass balance
double total_mAb_amount =
  A_central_serum +
  A_central_serum_es +
  C_FcRn_A_central_serum * g_VE +
  A_Tight + A_Leaky + A_lymph +
  A_rec_blood +
  A_rec_es +
  C_FcRn_A_rec * g_Ve1 +
  C_A_rec_I * g_REC_IV +
  C_A_rec_D * g_REC_DV;

double total_endo_amount =
  (C_en_central_serum * g_Vcentral_serum) +
  (C_en_central_serum_es * g_VE) +
  (C_FcRn_en_central_serum * g_VE) +
  en_Tight + en_Leaky +
  (C_Ly_en * g_Vlymph) +
  en_rec_blood +
  C_en_rec_I * g_REC_IV +
  C_en_rec_es * g_Ve1 +
  C_FcRn_en_rec * g_Ve1;

double cumulative_mAb_input = 15000;
double mAb_in_body = total_mAb_amount;
double mAb_degraded = A_mAb_degraded;
double mAb_mass_balance = cumulative_mAb_input - (mAb_in_body + mAb_degraded);

$CAPTURE
C_Central_Serum C_Lymph C_A_Tight C_A_Leaky
Conc_en_central_serum C_en_lymph C_en_tight C_en_leaky

C_en_REC_I
conc_A_rec_I
conc_A_rec_D

C_A_rec_Overall
A_rec_Overall

C_en_REC_Overall

FcRn_occ_mab_central_serum FcRn_occ_endo_central_serum FcRn_occ_total_central_serum FcRn_free_frac_central_serum
FcRn_occ_mab_rec FcRn_occ_endo_rec FcRn_occ_total_rec FcRn_free_frac_rec

FcRn_mass_balance_central_serum FcRn_mass_balance_rec

total_mAb_amount total_endo_amount mAb_in_body mAb_degraded
mAb_mass_balance cumulative_mAb_input
"



'


# =============================================================================
# 5. Endogenous IgG Steady-State Model (Female)
# =============================================================================
# Used to derive initial conditions for endogenous IgG
 
 

ENDO_MODEL_CODE_FEMALE <- endo_model_code_female <- "
$PROB
Endogenous IgG steady-state model (no therapeutic mAb) with mucosal fast/deep interstitial pools

$GLOBAL
double g_Vplasma;
double g_Vlymph;
double g_VE;
double g_Ve1;
double g_Ve2;
double g_Ve3;
double g_Vrec;
double g_Vvag;
double g_Vcer;
double g_Vrec_blood;
double g_Vvag_blood;
double g_Vcer_blood;
double g_VisfT;
double g_VisfL;
double g_Kp;
double g_REC_IV_fast;
double g_VAG_IV_fast;
double g_CER_IV_fast;
double g_REC_IV_deep;
double g_VAG_IV_deep;
double g_CER_IV_deep;

$PARAM @annotated
TVVlymph   : 5.2       : Lymph volume (L)
TVL        : 2.9       : Total lymph flow (L/day)
TVKp_en    : 0.8       : Fraction of interstitial space available for endogenous IgG distribution
TVRfT      : 0.945      : Reflection coefficient tight tissues
TVRfL      : 0.697       : Reflection coefficient leaky tissues
TVRflymph  : 0.2       : Lymphatic reflection coefficient

C_en0      : 80667     : Reference endogenous IgG conc (nM)
TVk0       : 15900     : IgG synthesis rate (nmol/day)
TVkup_en   : 1.0       : Endogenous IgG plasma uptake (1/day)
TVkdeg_en  : 3.13       : Endogenous IgG plasma degradation (1/day)
TVkup_t_en : 1     : Endogenous IgG tissue uptake (1/day)
TVkdeg_t_en: 3.13     : Endogenous IgG tissue degradation (1/day)
krecy_en   : 14.088     : Recycling rate constant (1/day), fixed
TVkon_en   : 8.12      : IgG-FcRn association (nM-1.day-1)
TVkoff_en  : 24106     : IgG-FcRn dissociation (1/day)

FcRn_tot_plasma : 40000 : FcRn conc plasma endosome (nM)
FcRn_tot_rec    : 40000 : FcRn conc rectum endosome (nM)
FcRn_tot_vag    : 40000 : FcRn conc vagina endosome (nM)
FcRn_tot_cer    : 40000 : FcRn conc cervix endosome (nM)

TVkdeep_in_rec  : 0  : Fast->deep exchange in rectum (1/day)
TVkdeep_out_rec : 0  : Deep->fast exchange in rectum (1/day)
TVkdeep_in      : 0  : Fast->deep exchange in vagina/cervix (1/day)
TVkdeep_out     : 0  : Deep->fast exchange in vagina/cervix (1/day)

$CMT @annotated
C_en_plasma      : Endogenous IgG in plasma (nM)
C_en_plasma_es   : Endogenous IgG in plasma endosome (nM)
C_FcRn_en_plasma : FcRn-IgG complex plasma endosome (nM)
C_en_lymph       : IgG in lymph (nM)
en_Tight         : IgG in tight tissue (nmol)
en_Leaky         : IgG in leaky tissue (nmol)
C_en_rec_I       : IgG in rectum fast interstitium (nM)
C_en_vag_I       : IgG in vagina fast interstitium (nM)
C_en_cer_I       : IgG in cervix fast interstitium (nM)
C_en_rec_D       : IgG in rectum deep interstitium (nM)
C_en_vag_D       : IgG in vagina deep interstitium (nM)
C_en_cer_D       : IgG in cervix deep interstitium (nM)
en_rec_blood     : IgG amount rectum vascular (nmol)
en_vag_blood     : IgG amount vagina vascular (nmol)
en_cer_blood     : IgG amount cervix vascular (nmol)
C_en_rec_es      : IgG rectum endosome (nM)
C_en_vag_es      : IgG vagina endosome (nM)
C_en_cer_es      : IgG cervix endosome (nM)
C_FcRn_en_rec    : FcRn-IgG rectum endosome (nM)
C_FcRn_en_vag    : FcRn-IgG vagina endosome (nM)
C_FcRn_en_cer    : FcRn-IgG cervix endosome (nM)

$OMEGA 0

$MAIN
double Vlymph = TVVlymph;
double L = TVL;
double Kp_en = TVKp_en;
double RfT = TVRfT;
double RfL = TVRfL;
double Rflymph = TVRflymph;

double Vplasma = 2.6;
double Visf = 15.6;
double VisfT = Visf*0.65;
double VisfL = Visf*0.35;
double LT = L*0.33;
double LL = L*0.67;

double VE = 0.31;
double Ve1 = 0.000105;
double Ve2 = 0.00013;
double Ve3 = 0.0001265;

double Vrec = 0.021;
double Vvag = 0.026;
double Vcer = 0.0253;

double Vrec_blood = 0.0022;
double Vvag_blood = 0.01;
double Vcer_blood = 0.009375;

double REC_IV_TOTAL = 0.0063;
double VAG_IV_TOTAL = 0.0078;
double CER_IV_TOTAL = 0.0075;

double REC_IV_FAST = REC_IV_TOTAL*0.5;
double VAG_IV_FAST = VAG_IV_TOTAL*0.5;
double CER_IV_FAST = CER_IV_TOTAL*0.5;

double REC_IV_DEEP = REC_IV_TOTAL*0.5;
double VAG_IV_DEEP = VAG_IV_TOTAL*0.5;
double CER_IV_DEEP = CER_IV_TOTAL*0.5;

double Qrec = 8.1504;
double Qvag = 3.6;
double Qcer = 5.78;

double REC_LF = Qrec*0.002;
double VAG_LF = Qvag*0.002;
double CER_LF = Qcer*0.002;
double fserum = 0.715;
double REC_VRC = 0.85;
double VAG_VRC = 0.85;
double CER_VRC = 0.85;
double REC_ISRC = 0.2;
double VAG_ISRC = 0.2;
double CER_ISRC = 0.2;

double k0 = TVk0;
double kon_en = TVkon_en;
double koff_en = TVkoff_en;
double kup_en = TVkup_en;
double kdeg_en = TVkdeg_en;
double kup_t_en = TVkup_t_en;
double kdeg_t_en = TVkdeg_t_en;
double CLup_en = kup_en * Vplasma;
double CLup_en_rec = kup_t_en * Vrec_blood;
double CLup_en_vag = kup_t_en * Vvag_blood;
double CLup_en_cer = kup_t_en * Vcer_blood;
double kdeep_in_rec = TVkdeep_in_rec;
double kdeep_out_rec = TVkdeep_out_rec;
double kdeep_in = 0;
double kdeep_out = 0;

// Save constants for TABLE / CAPTURE derived values
g_Vplasma = Vplasma;
g_Vlymph = Vlymph;
g_VE = VE;
g_Ve1 = Ve1;
g_Ve2 = Ve2;
g_Ve3 = Ve3;
g_Vrec = Vrec;
g_Vvag = Vvag;
g_Vcer = Vcer;
g_Vrec_blood = Vrec_blood;
g_Vvag_blood = Vvag_blood;
g_Vcer_blood = Vcer_blood;
g_VisfT = VisfT;
g_VisfL = VisfL;
g_Kp = Kp_en;
g_REC_IV_fast = REC_IV_FAST;
g_VAG_IV_fast = VAG_IV_FAST;
g_CER_IV_fast = CER_IV_FAST;
g_REC_IV_deep = REC_IV_DEEP;
g_VAG_IV_deep = VAG_IV_DEEP;
g_CER_IV_deep = CER_IV_DEEP;

// Fixed initialization requested by user: only 3 non-zero compartments
C_en_plasma_0 = 80667;
C_en_plasma_es_0 = 80000;
C_en_lymph_0 = 14000;

C_FcRn_en_plasma_0 = 0;
en_Tight_0 = 0;
en_Leaky_0 = 0;

C_en_rec_I_0 = 0;
C_en_vag_I_0 = 0;
C_en_cer_I_0 = 0;
C_en_rec_D_0 = 0;
C_en_vag_D_0 = 0;
C_en_cer_D_0 = 0;

en_rec_blood_0 = 0;
en_vag_blood_0 = 0;
en_cer_blood_0 = 0;

C_en_rec_es_0 = 0;
C_en_vag_es_0 = 0;
C_en_cer_es_0 = 0;

C_FcRn_en_rec_0 = 0;
C_FcRn_en_vag_0 = 0;
C_FcRn_en_cer_0 = 0;

$ODE
double C_FcRn_plasma = FcRn_tot_plasma - C_FcRn_en_plasma;
if(C_FcRn_plasma < 0) C_FcRn_plasma = 0;
double C_FcRn_rec = FcRn_tot_rec - C_FcRn_en_rec;
if(C_FcRn_rec < 0) C_FcRn_rec = 0;
double C_FcRn_vag = FcRn_tot_vag - C_FcRn_en_vag;
if(C_FcRn_vag < 0) C_FcRn_vag = 0;
double C_FcRn_cer = FcRn_tot_cer - C_FcRn_en_cer;
if(C_FcRn_cer < 0) C_FcRn_cer = 0;

double L_total = L;

dxdt_C_en_plasma =
  (1/Vplasma) *
  (
    k0 + L_total*C_en_lymph
    -Qrec*C_en_plasma + (Qrec-REC_LF)*en_rec_blood/Vrec_blood
    -Qvag*C_en_plasma + (Qvag-VAG_LF)*en_vag_blood/Vvag_blood
    -Qcer*C_en_plasma + (Qcer-CER_LF)*en_cer_blood/Vcer_blood
    -(1-RfT)*LT*C_en_plasma
    -(1-RfL)*LL*C_en_plasma
    -CLup_en*C_en_plasma
    +krecy_en*VE*C_FcRn_en_plasma
  );

dxdt_C_en_plasma_es =
  (1/VE) * (
    -kon_en*C_en_plasma_es*VE*C_FcRn_plasma
    +koff_en*C_FcRn_en_plasma*VE
    +CLup_en*C_en_plasma
    -kdeg_en*C_en_plasma_es*VE
  );

dxdt_C_FcRn_en_plasma =
  kon_en*C_FcRn_plasma*C_en_plasma_es
  -koff_en*C_FcRn_en_plasma
  -krecy_en*C_FcRn_en_plasma;

dxdt_en_Tight =
  (1-RfT)*LT*C_en_plasma
  -(1-Rflymph)*LT*en_Tight/(VisfT*Kp_en);

dxdt_en_Leaky =
  (1-RfL)*LL*C_en_plasma
  -(1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en);

dxdt_C_en_lymph =
  (
    (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en) +
    (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en) +
    (1-REC_ISRC)*REC_LF*C_en_rec_I +
    (1-VAG_ISRC)*VAG_LF*C_en_vag_I +
    (1-CER_ISRC)*CER_LF*C_en_cer_I
    -L_total*C_en_lymph
  ) / Vlymph;

dxdt_en_rec_blood =
  Qrec*C_en_plasma
  -(1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood)
  -CLup_en_rec*en_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*en_rec_blood/Vrec_blood
  +fserum*krecy_en*C_FcRn_en_rec*Ve1;

dxdt_C_en_rec_es =
  (1/Ve1) * (
    -kon_en*C_en_rec_es*Ve1*C_FcRn_rec
    +koff_en*C_FcRn_en_rec*Ve1
    +CLup_en_rec*(en_rec_blood/Vrec_blood)
    +CLup_en_rec*C_en_rec_I
    -kdeg_t_en*C_en_rec_es*Ve1
  );

dxdt_C_FcRn_en_rec =
  kon_en*C_FcRn_rec*C_en_rec_es
  -koff_en*C_FcRn_en_rec
  -krecy_en*C_FcRn_en_rec;

dxdt_C_en_rec_I =
  (((1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood))/REC_IV_FAST)
  -(((1-REC_ISRC)*REC_LF*C_en_rec_I)/REC_IV_FAST)
  -((CLup_en_rec*C_en_rec_I)/REC_IV_FAST)
  +((1-fserum)*krecy_en*C_FcRn_en_rec*(Ve1/REC_IV_FAST))
  -kdeep_in_rec*C_en_rec_I
  +kdeep_out_rec*C_en_rec_D;

dxdt_C_en_rec_D =0;

dxdt_en_vag_blood =
  Qvag*C_en_plasma
  -(1-VAG_VRC)*VAG_LF*(en_vag_blood/Vvag_blood)
  -CLup_en_vag*en_vag_blood/Vvag_blood
  -(Qvag-VAG_LF)*en_vag_blood/Vvag_blood
  +fserum*krecy_en*C_FcRn_en_vag*Ve2;

dxdt_C_en_vag_es =
  (1/Ve2) * (
    -kon_en*C_en_vag_es*Ve2*C_FcRn_vag
    +koff_en*C_FcRn_en_vag*Ve2
    +CLup_en_vag*(en_vag_blood/Vvag_blood)
    +CLup_en_vag*C_en_vag_I
    -kdeg_t_en*C_en_vag_es*Ve2
  );

dxdt_C_FcRn_en_vag =
  kon_en*C_FcRn_vag*C_en_vag_es
  -koff_en*C_FcRn_en_vag
  -krecy_en*C_FcRn_en_vag;

dxdt_C_en_vag_I =
  (((1-VAG_VRC)*VAG_LF*(en_vag_blood/Vvag_blood))/VAG_IV_FAST)
  -(((1-VAG_ISRC)*VAG_LF*C_en_vag_I)/VAG_IV_FAST)
  -((CLup_en_vag*C_en_vag_I)/VAG_IV_FAST)
  +((1-fserum)*krecy_en*C_FcRn_en_vag*(Ve2/VAG_IV_FAST))
  -kdeep_in*C_en_vag_I
  +kdeep_out*C_en_vag_D;

dxdt_C_en_vag_D =0;

dxdt_en_cer_blood =
  Qcer*C_en_plasma
  -(1-CER_VRC)*CER_LF*(en_cer_blood/Vcer_blood)
  -CLup_en_cer*en_cer_blood/Vcer_blood
  -(Qcer-CER_LF)*en_cer_blood/Vcer_blood
  +fserum*krecy_en*C_FcRn_en_cer*Ve3;

dxdt_C_en_cer_es =
  (1/Ve3) * (
    -kon_en*C_en_cer_es*Ve3*C_FcRn_cer
    +koff_en*C_FcRn_en_cer*Ve3
    +CLup_en_cer*(en_cer_blood/Vcer_blood)
    +CLup_en_cer*C_en_cer_I
    -kdeg_t_en*C_en_cer_es*Ve3
  );

dxdt_C_FcRn_en_cer =
  kon_en*C_FcRn_cer*C_en_cer_es
  -koff_en*C_FcRn_en_cer
  -krecy_en*C_FcRn_en_cer;

dxdt_C_en_cer_I =
  (((1-CER_VRC)*CER_LF*(en_cer_blood/Vcer_blood))/CER_IV_FAST)
  -(((1-CER_ISRC)*CER_LF*C_en_cer_I)/CER_IV_FAST)
  -((CLup_en_cer*C_en_cer_I)/CER_IV_FAST)
  +((1-fserum)*krecy_en*C_FcRn_en_cer*(Ve3/CER_IV_FAST))
  -kdeep_in*C_en_cer_I
  +kdeep_out*C_en_cer_D;

dxdt_C_en_cer_D =0;

$TABLE
double ss_C_en_plasma = C_en_plasma;
double ss_C_en_plasma_es = C_en_plasma_es;
double ss_C_FcRn_en_plasma = C_FcRn_en_plasma;
double ss_C_en_lymph = C_en_lymph;
double ss_en_Tight = en_Tight;
double ss_en_Leaky = en_Leaky;
double ss_C_en_rec_I = C_en_rec_I;
double ss_C_en_vag_I = C_en_vag_I;
double ss_C_en_cer_I = C_en_cer_I;
double ss_C_en_rec_D = C_en_rec_D;
double ss_C_en_vag_D = C_en_vag_D;
double ss_C_en_cer_D = C_en_cer_D;
double ss_en_rec_blood = en_rec_blood;
double ss_en_vag_blood = en_vag_blood;
double ss_en_cer_blood = en_cer_blood;
double ss_C_en_rec_es = C_en_rec_es;
double ss_C_en_vag_es = C_en_vag_es;
double ss_C_en_cer_es = C_en_cer_es;
double ss_C_FcRn_en_rec = C_FcRn_en_rec;
double ss_C_FcRn_en_vag = C_FcRn_en_vag;
double ss_C_FcRn_en_cer = C_FcRn_en_cer;

double C_en_tight = en_Tight / (g_VisfT * g_Kp + 1e-12);
double C_en_leaky = en_Leaky / (g_VisfL * g_Kp + 1e-12);

double C_en_rec_blood_conc = en_rec_blood / (g_Vrec_blood + 1e-12);
double C_en_vag_blood_conc = en_vag_blood / (g_Vvag_blood + 1e-12);
double C_en_cer_blood_conc = en_cer_blood / (g_Vcer_blood + 1e-12);

double C_en_plasma_endo_total = C_en_plasma_es + C_FcRn_en_plasma;
double C_en_rec_endo_total = C_en_rec_es + C_FcRn_en_rec;
double C_en_vag_endo_total = C_en_vag_es + C_FcRn_en_vag;
double C_en_cer_endo_total = C_en_cer_es + C_FcRn_en_cer;

double C_en_REC_Overall =
  (en_rec_blood + C_en_rec_I * g_REC_IV_fast + (C_en_rec_es + C_FcRn_en_rec) * g_Ve1) / g_Vrec;

double C_en_VAG_Overall =
  (en_vag_blood + C_en_vag_I * g_VAG_IV_fast + (C_en_vag_es + C_FcRn_en_vag) * g_Ve2) / g_Vvag;

double C_en_CER_Overall =
  (en_cer_blood + C_en_cer_I * g_CER_IV_fast + (C_en_cer_es + C_FcRn_en_cer) * g_Ve3) / g_Vcer;

double total_IgG_amount =
  (C_en_plasma * g_Vplasma) +
  (C_en_plasma_es * g_VE) +
  (C_FcRn_en_plasma * g_VE) +
  en_Tight + en_Leaky +
  (C_en_lymph * g_Vlymph) +
  en_rec_blood + en_vag_blood + en_cer_blood +
  C_en_rec_I * g_REC_IV_fast + C_en_vag_I * g_VAG_IV_fast + C_en_cer_I * g_CER_IV_fast +
  C_en_rec_es * g_Ve1 + C_en_vag_es * g_Ve2 + C_en_cer_es * g_Ve3 +
  C_FcRn_en_rec * g_Ve1 + C_FcRn_en_vag * g_Ve2 + C_FcRn_en_cer * g_Ve3;

$CAPTURE
ss_C_en_plasma ss_C_en_plasma_es ss_C_FcRn_en_plasma ss_C_en_lymph
ss_en_Tight ss_en_Leaky
ss_C_en_rec_I ss_C_en_vag_I ss_C_en_cer_I
ss_C_en_rec_D ss_C_en_vag_D ss_C_en_cer_D
ss_en_rec_blood ss_en_vag_blood ss_en_cer_blood
ss_C_en_rec_es ss_C_en_vag_es ss_C_en_cer_es
ss_C_FcRn_en_rec ss_C_FcRn_en_vag ss_C_FcRn_en_cer
C_en_tight C_en_leaky C_en_plasma_endo_total
C_en_rec_endo_total C_en_vag_endo_total C_en_cer_endo_total
C_en_rec_blood_conc C_en_vag_blood_conc C_en_cer_blood_conc
C_en_REC_Overall C_en_VAG_Overall C_en_CER_Overall
total_IgG_amount
"
 

# =============================================================================
# 6. Endogenous IgG Steady-State Model (Male)
# =============================================================================

# ===========================================================
# Same as female but without vagina/cervix
# ===========================================================

ENDO_MODEL_CODE_MALE <- "
$PROB
Endogenous IgG steady-state model (male anatomy; rectum only, no therapeutic mAb)

$GLOBAL
double g_Vplasma;
double g_Vlymph;
double g_VE;
double g_Ve1;
double g_Vrec;
double g_Vrec_blood;
double g_VisfT;
double g_VisfL;
double g_Kp;
double g_REC_IV_fast;
double g_REC_IV_deep;

$PARAM @annotated
TVVlymph   : 5.2       : Lymph volume (L)
TVL        : 2.9       : Total lymph flow (L/day)
TVKp_en    : 0.8        : Fraction of interstitial space available for endogenous IgG distribution
TVRfT      : 0.945      : Reflection coefficient tight tissues
TVRfL      : 0.697       : Reflection coefficient leaky tissues
TVRflymph  : 0.2       : Lymphatic reflection coefficient

C_en0      : 80667     : Reference endogenous IgG conc (nM)
TVk0       : 15900     : IgG synthesis rate (nmol/day)
TVkup_en   : 1.0       : Endogenous IgG plasma uptake (1/day)
TVkdeg_en  : 3.13         : Endogenous IgG plasma degradation (1/day)
TVkup_t_en : 1         : Endogenous IgG tissue uptake (1/day)
TVkdeg_t_en: 3.13         : Endogenous IgG tissue degradation (1/day)
krecy_en   : 14.088     : Recycling rate constant (1/day), fixed
TVkon_en   : 8.12      : IgG-FcRn association (nM-1.day-1)
TVkoff_en  : 24106     : IgG-FcRn dissociation (1/day)

FcRn_tot_plasma : 40000 : FcRn conc plasma endosome (nM)
FcRn_tot_rec    : 40000 : FcRn conc rectum endosome (nM)

TVkdeep_in_rec  : 0  : Fast->deep exchange in rectum (1/day)
TVkdeep_out_rec : 0  : Deep->fast exchange in rectum (1/day)

$CMT @annotated
C_en_plasma      : Endogenous IgG in plasma (nM)
C_en_plasma_es   : Endogenous IgG in plasma endosome (nM)
C_FcRn_en_plasma : FcRn-IgG complex plasma endosome (nM)
C_en_lymph       : IgG in lymph (nM)
en_Tight         : IgG in tight tissue (nmol)
en_Leaky         : IgG in leaky tissue (nmol)
C_en_rec_I       : IgG in rectum fast interstitium (nM)
C_en_rec_D       : IgG in rectum deep interstitium (nM)
en_rec_blood     : IgG amount rectum vascular (nmol)
C_en_rec_es      : IgG rectum endosome (nM)
C_FcRn_en_rec    : FcRn-IgG rectum endosome (nM)

$OMEGA 0

$MAIN
double Vlymph = TVVlymph;
double L = TVL;
double Kp_en = TVKp_en;
double RfT = TVRfT;
double RfL = TVRfL;
double Rflymph = TVRflymph;

double Vplasma = 2.6;
double Visf = 15.6;
double VisfT = Visf*0.65;
double VisfL = Visf*0.35;
double LT = L*0.33;
double LL = L*0.67;

double VE = 0.31;
double Ve1 = 0.000105;

double Vrec = 0.021;
double Vrec_blood = 0.0022;
double REC_IV_TOTAL = 0.0063;
double REC_IV_FAST = REC_IV_TOTAL*0.5;
double REC_IV_DEEP = REC_IV_TOTAL*0.5;

double Qrec = 8.1504;
double REC_LF = Qrec*0.002;
double fserum = 0.715;
double REC_VRC = 0.85;
double REC_ISRC = 0.2;

double k0 = TVk0;
double kon_en = TVkon_en;
double koff_en = TVkoff_en;
double kup_en = TVkup_en;
double kdeg_en = TVkdeg_en;
double kup_t_en = TVkup_t_en;
double kdeg_t_en = TVkdeg_t_en;
double CLup_en = kup_en * Vplasma;
double CLup_en_rec = kup_t_en * Vrec_blood;
double kdeep_in_rec = TVkdeep_in_rec;
double kdeep_out_rec = TVkdeep_out_rec;

g_Vplasma = Vplasma;
g_Vlymph = Vlymph;
g_VE = VE;
g_Ve1 = Ve1;
g_Vrec = Vrec;
g_Vrec_blood = Vrec_blood;
g_VisfT = VisfT;
g_VisfL = VisfL;
g_Kp = Kp_en;
g_REC_IV_fast = REC_IV_FAST;
g_REC_IV_deep = REC_IV_DEEP;

C_en_plasma_0 = 80667;
C_en_plasma_es_0 = 80667;
C_en_lymph_0 = 14000;

C_FcRn_en_plasma_0 = 0;
en_Tight_0 = 0;
en_Leaky_0 = 0;
C_en_rec_I_0 = 0;
C_en_rec_D_0 = 0;
en_rec_blood_0 = 0;
C_en_rec_es_0 = 0;
C_FcRn_en_rec_0 = 0;

$ODE
double C_FcRn_plasma = FcRn_tot_plasma - C_FcRn_en_plasma;
if(C_FcRn_plasma < 0) C_FcRn_plasma = 0;
double C_FcRn_rec = FcRn_tot_rec - C_FcRn_en_rec;
if(C_FcRn_rec < 0) C_FcRn_rec = 0;

double L_total = L;

dxdt_C_en_plasma =
  (1/Vplasma) *
  (
    k0 + L_total*C_en_lymph
    -Qrec*C_en_plasma + (Qrec-REC_LF)*en_rec_blood/Vrec_blood
    -(1-RfT)*LT*C_en_plasma
    -(1-RfL)*LL*C_en_plasma
    -CLup_en*C_en_plasma
    +krecy_en*VE*C_FcRn_en_plasma
  );

dxdt_C_en_plasma_es =
  (1/VE) * (
    -kon_en*C_en_plasma_es*VE*C_FcRn_plasma
    +koff_en*C_FcRn_en_plasma*VE
    +CLup_en*C_en_plasma
    -kdeg_en*C_en_plasma_es*VE
  );

dxdt_C_FcRn_en_plasma =
  kon_en*C_FcRn_plasma*C_en_plasma_es
  -koff_en*C_FcRn_en_plasma
  -krecy_en*C_FcRn_en_plasma;

dxdt_en_Tight =
  (1-RfT)*LT*C_en_plasma
  -(1-Rflymph)*LT*en_Tight/(VisfT*Kp_en);

dxdt_en_Leaky =
  (1-RfL)*LL*C_en_plasma
  -(1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en);

dxdt_C_en_lymph =
  (
    (1-Rflymph)*LT*en_Tight/(VisfT*Kp_en) +
    (1-Rflymph)*LL*en_Leaky/(VisfL*Kp_en) +
    (1-REC_ISRC)*REC_LF*C_en_rec_I
    -L_total*C_en_lymph
  ) / Vlymph;

dxdt_en_rec_blood =
  Qrec*C_en_plasma
  -(1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood)
  -CLup_en_rec*en_rec_blood/Vrec_blood
  -(Qrec-REC_LF)*en_rec_blood/Vrec_blood
  +fserum*krecy_en*C_FcRn_en_rec*Ve1;

dxdt_C_en_rec_es =
  (1/Ve1) * (
    -kon_en*C_en_rec_es*Ve1*C_FcRn_rec
    +koff_en*C_FcRn_en_rec*Ve1
    +CLup_en_rec*(en_rec_blood/Vrec_blood)
    +CLup_en_rec*C_en_rec_I
    -kdeg_t_en*C_en_rec_es*Ve1
  );

dxdt_C_FcRn_en_rec =
  kon_en*C_FcRn_rec*C_en_rec_es
  -koff_en*C_FcRn_en_rec
  -krecy_en*C_FcRn_en_rec;

dxdt_C_en_rec_I =
  (((1-REC_VRC)*REC_LF*(en_rec_blood/Vrec_blood))/REC_IV_FAST)
  -(((1-REC_ISRC)*REC_LF*C_en_rec_I)/REC_IV_FAST)
  -((CLup_en_rec*C_en_rec_I)/REC_IV_FAST)
  +((1-fserum)*krecy_en*C_FcRn_en_rec*(Ve1/REC_IV_FAST))
  -kdeep_in_rec*C_en_rec_I
  +kdeep_out_rec*C_en_rec_D;

dxdt_C_en_rec_D =0;

$TABLE
double ss_C_en_plasma = C_en_plasma;
double ss_C_en_plasma_es = C_en_plasma_es;
double ss_C_FcRn_en_plasma = C_FcRn_en_plasma;
double ss_C_en_lymph = C_en_lymph;
double ss_en_Tight = en_Tight;
double ss_en_Leaky = en_Leaky;
double ss_C_en_rec_I = C_en_rec_I;
double ss_C_en_rec_D = C_en_rec_D;
double ss_en_rec_blood = en_rec_blood;
double ss_C_en_rec_es = C_en_rec_es;
double ss_C_FcRn_en_rec = C_FcRn_en_rec;

double C_en_tight = en_Tight / (g_VisfT * g_Kp + 1e-12);
double C_en_leaky = en_Leaky / (g_VisfL * g_Kp + 1e-12);

double C_en_rec_blood_conc = en_rec_blood / (g_Vrec_blood + 1e-12);

double C_en_plasma_endo_total = C_en_plasma_es + C_FcRn_en_plasma;
double C_en_rec_endo_total = C_en_rec_es + C_FcRn_en_rec;

double C_en_REC_Overall =
  (en_rec_blood + C_en_rec_I * g_REC_IV_fast + C_en_rec_D * g_REC_IV_deep + (C_en_rec_es + C_FcRn_en_rec) * g_Ve1) / g_Vrec;

double total_IgG_amount =
  (C_en_plasma * g_Vplasma) +
  (C_en_plasma_es * g_VE) +
  (C_FcRn_en_plasma * g_VE) +
  en_Tight + en_Leaky +
  (C_en_lymph * g_Vlymph) +
  en_rec_blood +
  C_en_rec_I * g_REC_IV_fast +
  C_en_rec_D * g_REC_IV_deep +
  C_en_rec_es * g_Ve1 +
  C_FcRn_en_rec * g_Ve1;

$CAPTURE
ss_C_en_plasma ss_C_en_plasma_es ss_C_FcRn_en_plasma ss_C_en_lymph
ss_en_Tight ss_en_Leaky
ss_C_en_rec_I ss_C_en_rec_D
ss_en_rec_blood
ss_C_en_rec_es
ss_C_FcRn_en_rec
C_en_tight C_en_leaky C_en_plasma_endo_total
C_en_rec_endo_total
C_en_rec_blood_conc
C_en_REC_Overall
total_IgG_amount
"



# =============================================================================
# Parameters 
# =============================================================================

PARAM_NAMES_MONO <- c("TVkup_A", "TVkup_t_A", "TVkdeg_A", "TVkdeg_t_A",
                       "TVkon_A", "TVkoff_A", "TVkup_en", "TVkdeg_en",
                       "TVkup_t_en", "TVkdeg_t_en")

# VRC01 parameters
 
PARAMS_VRC01_WHITE_FEMALE     <- c(2.2, 2.2, 10, 20, 8.12, 24106, 1, 3.13, 1, 3.13)
PARAMS_VRC01_WHITE_MALE       <- c(2.2, 2.2, 10, 20, 8.12, 24106, 1, 3.13, 1, 3.13)
PARAMS_VRC01_NONWHITE_FEMALE  <- c(2.2, 2.2, 15, 30, 8.12, 24106, 1, 3.13, 1, 3.13)
PARAMS_VRC01_NONWHITE_MALE    <- c(2.2, 2.2, 15, 30, 8.12, 24106, 1, 3.13, 1, 3.13)

# VRC01LS parameters
 
PARAMS_VRC01LS_WHITE_FEMALE   <- c(2.2, 2.2, 7.5, 45, 19.27, 4820, 1, 3.13, 1, 3.13)
PARAMS_VRC01LS_WHITE_MALE     <- c(2.2, 2.2, 18, 30, 19.27, 4820, 1, 3.13, 1, 3.13)
PARAMS_VRC01LS_NONWHITE_FEMALE <- c(2.2, 2.2, 9, 45, 19.27, 4820, 1, 3.13, 1, 3.13)
PARAMS_VRC01LS_NONWHITE_MALE  <- c(2.2, 2.2, 21.6, 30, 19.27, 4820, 1, 3.13, 1, 3.13)

# Nested list for easy lookup
PARAMS_BY_SEX_RACE_MAB <- list(
  VRC01 = list(
    female = list(
      White      = setNames(PARAMS_VRC01_WHITE_FEMALE, PARAM_NAMES_MONO),
      `Non-White` = setNames(PARAMS_VRC01_NONWHITE_FEMALE, PARAM_NAMES_MONO)
    ),
    male = list(
      White      = setNames(PARAMS_VRC01_WHITE_MALE, PARAM_NAMES_MONO),
      `Non-White` = setNames(PARAMS_VRC01_NONWHITE_MALE, PARAM_NAMES_MONO)
    )
  ),
  VRC01LS = list(
    female = list(
      White      = setNames(PARAMS_VRC01LS_WHITE_FEMALE, PARAM_NAMES_MONO),
      `Non-White` = setNames(PARAMS_VRC01LS_NONWHITE_FEMALE, PARAM_NAMES_MONO)
    ),
    male = list(
      White      = setNames(PARAMS_VRC01LS_WHITE_MALE, PARAM_NAMES_MONO),
      `Non-White` = setNames(PARAMS_VRC01LS_NONWHITE_MALE, PARAM_NAMES_MONO)
    )
  )
)


# =============================================================================
# Endogenous IgG Steady-State Initial Conditions
# Derived from 120-day simulation with FcRn = 40,000 nM
# No deep ISF for endogenous IgG in any tissue
# =============================================================================

ENDO_INIT_FEMALE <- list(
  C_en_plasma      = 61754,
  C_en_plasma_es   = 15075,
  C_FcRn_en_plasma = 33415,
  C_Ly_en          = 13740,
  en_Tight         = 4246,    # multiply by (15.6 * 0.65 * 0.8) in $MAIN
  en_Leaky         = 23389,   # multiply by (15.6 * 0.35 * 0.8) in $MAIN
  en_rec_blood_conc = 61848,  # multiply by Vrec_blood in $MAIN
  C_en_rec_es      = 309445,
  C_FcRn_en_rec    = 39620,
  C_en_rec_I       = 11018,
  C_en_rec_D       = 0,
  en_vag_blood_conc = 61702,  # multiply by Vvag_blood in $MAIN
  C_en_vag_es      = 1473135,
  C_FcRn_en_vag    = 39920,
  C_en_vag_I       = 5550,
  C_en_vag_D       = 0,
  en_cer_blood_conc = 61768,  # multiply by Vcer_blood in $MAIN
  C_en_cer_es      = 1444798,
  C_FcRn_en_cer    = 39918,
  C_en_cer_I       = 6840,
  C_en_cer_D       = 0,
  C_en_REC_Overall = 9877,
  C_en_VAG_Overall = 32130,
  C_en_CER_Overall = 31326
)

ENDO_INIT_MALE <- list(
  C_en_plasma      = 62896,
  C_en_plasma_es   = 16279,
  C_FcRn_en_plasma = 33827,
  C_Ly_en          = 13960,
  en_Tight         = 4324,
  en_Leaky         = 23822,
  en_rec_blood_conc = 62991,
  C_en_rec_es      = 318280,
  C_FcRn_en_rec    = 39630,
  C_en_rec_I       = 11202,
  C_en_rec_D       = 0,
  C_en_REC_Overall = 10069
)


 