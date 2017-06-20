(**

Reference : "Initial Semantics for Strengthened Signatures" (André Hirschowitz , Marco Maggesi)

Let (H, θ) be a strengthened signature, M an endo-functor.
If M has a structure of (left) module over a monad T, then it can be lifted to endow
H(M) with a structure of module over T.

Let T be the initial Id+H algebra. Then T is the initial representation in the sense of H&M.

*)
Require Import UniMath.Foundations.PartD.
Require Import UniMath.CategoryTheory.PointedFunctors.
Require Import UniMath.CategoryTheory.PointedFunctorsComposition.


Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.functor_categories.
Local Open Scope cat.
Require Import UniMath.SubstitutionSystems.Signatures.
Require Import UniMath.SubstitutionSystems.Notation.
Require Import UniMath.CategoryTheory.LModules.
Require Import UniMath.SubstitutionSystems.SubstitutionSystems.
Require Import UniMath.CategoryTheory.Monads.
Require Import UniMath.CategoryTheory.whiskering.

Require Import UniMath.SubstitutionSystems.MonadsFromSubstitutionSystems.
Require Import UniMath.CategoryTheory.EndofunctorsMonoidal.
Require Import UniMath.CategoryTheory.HorizontalComposition.

Require Import UniMath.CategoryTheory.FunctorAlgebras.
Require Import UniMath.CategoryTheory.limits.bincoproducts.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.CocontFunctors.
Require Import UniMath.CategoryTheory.Presheaf.
Require Import UniMath.SubstitutionSystems.LiftingInitial_alt.
Require Import UniMath.SubstitutionSystems.GenMendlerIteration_alt.
Require Import UniMath.CategoryTheory.limits.initial.

(** A monad is a pointed endofunctor *)
Definition ptd_from_mon {C:precategory} hsC (T:Monad C) : precategory_Ptd C hsC :=
  ((T:functor C C),, η T).

(** Let (Z, e : 1 -> Z) be a pointed endofunctor.
Then e is a morphism (actually the initial morphism) in the category of pointed endofunctors *)
Lemma is_ptd_mor_pt {C:precategory} hs (F:ptd_obj C) : is_ptd_mor _ (F:=id_Ptd C hs) (ptd_pt _ F).
Proof.
  intro c; apply id_left.
Qed.

Definition ptd_mor_pt {C:precategory} hs (F:ptd_obj C) : ptd_mor _ (id_Ptd C hs) F :=
  (ptd_pt _ F ,, is_ptd_mor_pt hs F).

Local Notation σ := (lm_mult _).

Section SignatureLiftModule.
  Variables (C:precategory) (hsC : has_homsets C)
            (D:precategory) (hsD : has_homsets D)
           (H : Signature C hsC D hsD).

  (** The forgetful functor from pointed endofunctors to endofunctors *)
  Local Notation "'U'" := (functor_ptd_forget C hsC).
  (** The precategory of pointed endofunctors on [C] *)
  Local Notation "'Ptd'" := (precategory_Ptd C hsC).
  (** The category of endofunctors on [C] *)
  Local Notation "'EndC'":= ([C, C, hsC]) .
  Variables (T:Monad C) (M: LModule T C).

  Local Notation Mf := (M : functor _ _).
  Local Notation "'p' T" := (ptd_from_mon hsC T) (at level 3).

  (** The pointed functor TT *)
  Let  T2 := (ptd_composite _ hsC (p T) (p T)) .

  (** The multiplication of a monad is a morphism of pointed endofunctors *)
  Lemma is_ptd_mor_μ : is_ptd_mor _ (F:= T2) (G:=p T)  (μ T).
  Proof.
    intro c.
    cbn.
    rewrite <- assoc.
    etrans; [|apply id_right].
    apply cancel_precomposition.
    apply Monad_law2.
  Qed.

  Definition ptd_mor_from_μ : ptd_mor _ T2 (p T) := (_ ,, is_ptd_mor_μ).


  Let strength_law1_pw M x   :=
    nat_trans_eq_pointwise
      (θ_Strength1_int_implies_θ_Strength1 _ _ _ _ _ _ (Sig_strength_law1 _ _ _ _ H ) M) x.

  (** A pointwise version of the second strength law with only one identity instead
    of two α_functor *)
  Lemma strength_law2_pw :
    ∏ (X : EndC) (Z Z' : Ptd) x,
    ((theta H) (X ⊗ (Z p• Z')) : nat_trans _ _) x =
    ((theta H) (X ⊗ Z') •• (U Z):nat_trans _ _) x
      · ((theta H) ((functor_compose hsC hsC (U Z') X) ⊗ Z):nat_trans _ _) x
      · (# H (identity (functor_compose hsC hsC (U Z ∙ U Z') X)
          :
          [C, C, hsC] ⟦ functor_compose hsC hsC (U Z) (U Z' ∙ X : [C, C, hsC]),
          functor_compose hsC hsC (U Z ∙ U Z') X ⟧) : nat_trans _ _) x.
  Proof.
    intros X Z Z' x.
    etrans; revgoals.
    apply ( nat_trans_eq_pointwise (θ_Strength2_int_implies_θ_Strength2 _ _ _ _ _ _
                                           (Sig_strength_law2 _ _ _ _ H) X Z Z' _
           (identity _) ) x) .
    etrans;[eapply pathsinv0;apply id_right|].
    apply cancel_precomposition.
    eapply pathsinv0.
    etrans. eapply nat_trans_eq_pointwise.
    eapply (functor_id H).
    apply idpath.
  Qed.

  Local Notation θ_nat_2_pw := (θ_nat_2_pointwise _ _ _ _ H (theta H)).
  Local Notation θ_nat_1_pw := (θ_nat_1_pointwise _ _ _ _ H (theta H) ).


  (** The module multiplication is given by

         Θ_M,T        H(σ)
H(M) T ------> H(MT) ------> H(M)

   *)
  Local Definition lift_lm_mult : [C,D, hsD] ⟦  T ∙ H Mf, H Mf⟧ :=
    nat_trans_comp ((theta H) ((M : C ⟶ C),, ptd_from_mon hsC T)) (# H (σ M)).

  Local Definition lift_LModule_data : LModule_data T D :=
    tpair (fun x=> [C,D, hsD] ⟦  T ∙ x, x⟧) (H Mf) lift_lm_mult.

  Local Lemma lift_lm_mult_laws : LModule_laws _ lift_LModule_data.
  Proof.
    split.
    - intro c.
      etrans.
      apply assoc.
      etrans.
      apply cancel_postcomposition.
      eapply ( θ_nat_2_pw Mf (id_Ptd C hsC) (p T) (ptd_mor_pt hsC _) c).
      etrans.
      eapply cancel_postcomposition.
      rewrite (horcomp_pre_post _ _ (category_pair _ hsC )).
      rewrite (functor_comp H).
      etrans; [apply assoc|].
      apply cancel_postcomposition.
      apply strength_law1_pw.
      etrans;[|apply id_right].
      rewrite <- assoc.
      eapply cancel_precomposition.
      etrans.
      apply functor_comp_pw.
      etrans; [|apply (nat_trans_eq_pointwise (functor_id H Mf))].
      apply functor_cancel_pw.
      apply (nat_trans_eq hsC).
      eapply (LModule_law1).
    - intro c.
      cbn.
      etrans.
      rewrite assoc.
      apply cancel_postcomposition.
      etrans.
      apply (θ_nat_2_pw Mf _ _ (ptd_mor_from_μ)  c).
      apply cancel_postcomposition.
      apply (strength_law2_pw Mf (p T) (p T)).
      etrans; revgoals.
      rewrite <- assoc.
      apply cancel_precomposition.
      rewrite assoc;      apply cancel_postcomposition.
      eapply pathsinv0.
      apply (θ_nat_1_pw _ _ (σ M) (p T) c).
      cbn.
      repeat rewrite <- assoc.
      apply cancel_precomposition.
      apply cancel_precomposition.
      etrans; revgoals.
      eapply pathsinv0.
      apply (functor_comp_pw hsC hsD H).
      etrans.
      apply cancel_precomposition.
      apply (functor_comp_pw hsC hsD H).
      etrans.
      apply (functor_comp_pw hsC hsD H).
      apply functor_cancel_pw.
      apply (nat_trans_eq hsC).
      intro x.
      cbn.
      repeat rewrite id_left.
      rewrite functor_id,id_right.
      apply LModule_law2.
  Qed.

  Local Definition lift_lmodule : LModule T D := (lift_LModule_data,, lift_lm_mult_laws).
End SignatureLiftModule.

Section InitialRep.
  (** ** Some variables and assumptions *)

  (** Assume having a precategory [C] whose hom-types are sets *)
  Variable C : precategory.
  Variable hs : has_homsets C.

  Variable CP : BinCoproducts C.

  Local Notation "'EndC'":= ([C, C, hs]) .
  Let hsEndC : has_homsets EndC := functor_category_has_homsets C C hs.
  Let CPEndC : BinCoproducts EndC := BinCoproducts_functor_precat _ _ CP hs.

  Variable H : Signature C hs C hs.

  Let θ := theta H.

  Let θ_strength1_int := Sig_strength_law1 _ _ _ _ H.
  Let θ_strength2_int := Sig_strength_law2 _ _ _ _ H.
  Let θ_nat_2_pw := (θ_nat_2_pointwise _ _ _ _ H (theta H)).
  Let θ_nat_1_pw := (θ_nat_1_pointwise _ _ _ _ H (theta H)).

  Let Id_H
    : functor EndC EndC
    := BinCoproduct_of_functors _ _ CPEndC
                                (constant_functor _ _ (functor_identity _ : EndC))
                                H.

  Let Alg : precategory := FunctorAlg Id_H hsEndC.

  (** The precategory of pointed endofunctors on [C] *)
  Local Notation "'Ptd'" := (precategory_Ptd C hs).
  (** The category of endofunctors on [C] *)
  Local Notation "'EndC'":= ([C, C, hs]) .
  (** The product of two precategories *)

  Local Notation "'p' T" := (ptd_from_alg T) (at level 3).
  Local Notation "f ⊕ g" := (BinCoproductOfArrows _ (CPEndC _ _ ) (CPEndC _ _ ) f g) (at level 40).
  Local Notation η := @eta_from_alg.

  (** Let T be an hss.
  then τ : H T --> T is a module morphism
   *)
  Section TauModuleMorphism.
    Variable T : hss CP H.
    Local Notation T_mon := (Monad_from_hss _ _ _ _ T).
    Local Notation T_mod := (tautological_LModule T_mon).
    Local Notation HT_mod := (lift_lmodule _ _ _ _ H _ T_mod).

    Lemma τ_lmodule_laws : LModule_Mor_laws T_mon (T:=HT_mod) (T' := T_mod) (τ T).
    Proof.
      intro a.
      eapply pathsinv0.
      (* It is precisely the square diagram satisfied by μ = { id } *)
      exact( nat_trans_eq_pointwise (fbracket_τ T  (Z:= p T)(identity _ )) a).
    Qed.

    Definition τ_lmodule_mor :  LModule_Mor  _ _ _ :=
      tpair (fun x => LModule_Mor_laws _ x) _ τ_lmodule_laws.
  End TauModuleMorphism.


  (**
      Let (M, τ_M) be a representation in the sense of Hirschowitz & Maggesi :
      - M is a monad
      - τ_M : HM ---> M is a module morphism

      Then there exists a unique monad morphism j : T --> M that is compatible with τ_M, τ_T
     where T is the initial HSS.

      In other words, T is the initial representation in the sense of H&M

   *)

  Variables (IC : Initial C) (CC : Colims_of_shape nat_graph C) (HH : is_omega_cocont H).
  Variables (M:Monad C).

  Let T := InitHSS _ _ CP IC CC H HH.

  Local Notation T_hss := (T:hss _ _).
  Local Notation T_alg := (alg_from_hss _ _ _ _ T).
  Local Notation T_mon := (Monad_from_hss _ _ _ _ T).
  Local Notation T_func := (T_mon : functor _ _).
  Local Notation T_mod := (tautological_LModule T_mon).
  Local Notation HT_mod := (lift_lmodule _ _ _ _ H _ T_mod).

  Local Notation M_mod := (tautological_LModule M).
  Local Notation HM_mod := (lift_lmodule _ _ _ _ H _ M_mod).

  Variable (τ_M: LModule_Mor M HM_mod M_mod).

  Local Definition M_alg : Alg.
  Proof.
    eapply (tpair (fun x => EndC ⟦ Id_H x, x ⟧) (M:functor _ _)).
    eapply BinCoproductArrow.
    apply Monads.η.
    apply τ_M.
  Defined.

  Lemma eq_η : SubstitutionSystems.η M_alg = (Monads.η  M:nat_trans _ _).
    apply (nat_trans_eq hs).
    intro x.
    apply BinCoproductIn1Commutes.
  Qed.

  Lemma eq_τ : τ M_alg = (τ_M:nat_trans _ _).
    apply (nat_trans_eq hs).
    intro x.
    apply BinCoproductIn2Commutes.
  Qed.

  (*
  Lemma eq_p : p M_alg = ptd_from_mon hs M.
  Proof.
    cbn.
    unshelve eapply (total2_paths_f ).
    reflexivity.
    cbn.
    apply eq_η.
  Qed.
*)

  Lemma bracket_prop' (Z : Ptd)( f : Ptd ⟦ Z, p M_alg ⟧)
    : bracket_property' C hs CP H M_alg f
                        (compose (C:=EndC) (  (M:functor _ _)∘(pr1 f):nat_trans (_  ∙ `M_alg)(_  ∙ `M_alg)) (μ M)).
  Proof.
    eapply whole_from_parts'.
    split.
    - rewrite eq_η, assoc.
      apply (nat_trans_eq hs).
      intro x.
      etrans;revgoals.
      {
        (* eapply (cancel_postcomposition EndC (pr1 Z) (_  ∙ `M_alg) _ _ _ (μ M)). *)
        apply cancel_postcomposition.
        apply (nat_trans_ax (Monads.η M)).
      }
      rewrite <- assoc.
      etrans; revgoals.
      { apply cancel_precomposition.
        eapply pathsinv0.
        apply Monad_law1.
      }
      apply pathsinv0,id_right.
    - rewrite eq_τ, functor_comp, assoc, assoc.
      apply (nat_trans_eq hs).
      intro x.
      etrans;revgoals.
      { apply cancel_postcomposition.
        apply (nat_trans_ax τ_M).
      }
      etrans;revgoals.
      { rewrite <- assoc.
        apply cancel_precomposition.
        eapply pathsinv0.
        apply (LModule_Mor_σ _ τ_M).
      }
      rewrite assoc.
      apply cancel_postcomposition.
      etrans;[|eapply pathsinv0;apply assoc].
      apply cancel_postcomposition.
      apply pathsinv0.
      assert (h:= ( (θ_nat_2_pw (M:functor _ _) Z _ f x))).
      cbn in h.
      rewrite (horcomp_id_postwhisker ) in h; try exact hs.
      etrans;[|apply h].
      apply cancel_precomposition.
      clear h.
      clear.
      set (M' := M : functor _ _).
      apply ( (@maponpaths _ (C⟦ (M'∙H M':functor _ _) x, (H (M' ∙ M'):functor _ _) x ⟧)
                               (fun (X:nat_trans (functor_identity C) M') =>
                                  ((theta H) ((M':EndC) ⊗ ((M',,X):Ptd))
                                       :nat_trans _ _) x))).
      apply pathsinv0,eq_η.
  Qed.

 Definition bracket_rep  : bracket' _ hs CP H M_alg.
    intros Z f.
    exists (compose (C:=EndC) (  (M:functor _ _)∘(pr1 f):nat_trans (_  ∙ `M_alg)(_  ∙ `M_alg)) (μ M)).
    apply bracket_prop'.
 Defined.
  Definition rep_to_hss : hss' _ hs CP H := (M_alg,, bracket_rep).


  (** j : T --> M is the initial Id+H-algebra morphism *)
  Let j : Alg ⟦T_alg, M_alg⟧ := InitialArrow _ M_alg.
  (** j is a monad morphism (following Ralph's proof). For the square diagram,
     we show that both parts satisfies the same Mendler iterator characteristic equation*)
  Let j_hss : ishssMor' C hs CP H (T:=T_hss) (T' :=rep_to_hss) j.
    apply ishssMor_InitAlg.
  Qed.
  (* manque un whole_from/to_parts pour les hss_Mor *)

  Lemma j_mon : Monad_Mor_laws (T:=T_mon) (T':=M) (mor_from_algebra_mor _ _ _ j).
  Proof.
    split.
    - intro a.
      specialize (j_hss _ (identity _)).
      assert (h := (nat_trans_eq_pointwise j_hss a )).
      etrans; [apply h|].
      rewrite id_left.
      apply  assoc.

          kcbn in j_hss.

      apply (nat_trans_eq_pointwise (a:= compose (C:=EndC)  (μ T_mon) j_mor)
                                    (a':= compose(C:=EndC)
                                                 (compose (C:=EndC)
                                                          (a:=_∙_)
                                                          (b:=_∙_)
                                                          (c:=_∙_)
                                                          (j_mor ø T_mon ) (M ∘ j_mor) )
                                                 (μ M))).



  Let InitialEndC : Initial EndC.
  Proof.
    apply Initial_functor_precat, IC.
  Defined.

  Let Colims_of_shape_nat_graph_EndC : Colims_of_shape nat_graph EndC.
  Proof.
    apply colimits.ColimsFunctorCategory_of_shape, CC.
  Defined.


  Let is_omega_cocont_Id_H' := LiftingInitial_alt .is_omega_cocont_Id_H C hs CP H HH.

  Local Notation j_mor := ((mor_from_algebra_mor _ _ _ j):nat_trans _ _).

  (**
  Following Ralph's proof : we want to prove the square diagram for the monad morphism induced by
  the initial algebra morphism j : T --> M :
<<<<<<<<
       jj
  TT ------> MM
   |         |
μ_T|         | μ_M
   |         |
   V         V
   T ------> M
       j
>>>>>>>>>

  The strategy is to show that both paths of the diagram satisfy the characteristic equation of
  the same Mendler iterator. We use Lemma 8 from "Heteregenous substitution system revisited"
  (Benedikt Ahrens & Ralph Matthes) with the following parameters :

    X := M
    L Z := Z·T
    F Z := (Id+H) Z

  And for any Z : EndC, h : LZ -> X

    ψ_Z(h)  := [j, τ_M ∘ H h ∘ Θ_Z,(T,η)]

   *)

  Let L := (pre_composition_functor C C C hs hs T_func).
  Let X := (M:functor _ _).

  (* inspired by LiftingInitial_alt *)
  Local Lemma HL : is_omega_cocont L.
  Proof.
    apply CocontFunctors.is_omega_cocont_pre_composition_functor, CC.
  Defined.
  Let isInitial_precomp' : isInitial [C, C, hs] (L InitialEndC) :=
    LiftingInitial_alt.isInitial_pre_comp C hs IC p T_hss : isInitial [C, C, hs] (L InitialEndC).


  Local Definition ψ_pw Z : _ ⟦ψ_source hsEndC X L Z, ψ_target Id_H hsEndC X L Z⟧ .
  Proof.
    - intros h.
      cbn.
      eapply (BinCoproductArrow EndC (a:= `T_hss) (b:= functor_composite `T_hss (H Z)) (CPEndC _ _) (c:=X)).
      + apply j.
      + apply ((θ  (Z ⊗ (p T_hss)))·#H h· (τ_M:nat_trans _ _)).
  Defined.

  Local Lemma ψ_nt : is_nat_trans _ _ ψ_pw.
  Proof.
    intros x x' a.
    cbn in a.
    apply weqfunextsec.
    intros f.
    eapply (nat_trans_eq hs).
    intro c.
    etrans; revgoals.
    eapply pathsinv0.
    eapply (precompWithBinCoproductArrow C (CP _ _) (CP _ _)
                                         (identity _) (((# H a):nat_trans _ _) (T_func c))).
    eapply BinCoproductArrow_eq.
    + eapply pathsinv0,id_left.
    + apply pathsinv0.
      etrans;[eapply assoc|].
      apply cancel_postcomposition.
      etrans;[eapply assoc|].
      etrans.
      eapply cancel_postcomposition.
      eapply (θ_nat_1_pw _ _ a (p T_alg)).
      rewrite <- assoc.
      apply cancel_precomposition.
      etrans; revgoals.
      eapply pathsinv0.
      eapply nat_trans_eq_pointwise.
      eapply (functor_comp H (_:EndC⟦ T_mon ∙ x', T_mon ∙ x⟧) ).
      apply cancel_postcomposition.
      apply functor_cancel_pw.
      apply (nat_trans_eq hs).
      intro c'.
      etrans;[|apply id_right].
      apply cancel_precomposition.
      eapply (functor_id   x).
  Qed.

  Local Definition ψ  : (PreShv EndC)⟦ψ_source hsEndC X L , ψ_target Id_H hsEndC X L⟧ :=
    (ψ_pw ,, ψ_nt).

  (** Unicity of the Mendler iterator characteristized by its equation *)
  Local Definition uniq_iter :
    ∃! h : [C, C, hs] ⟦ L `T_hss, X ⟧,
           # L (alg_map Id_H T_alg) · h = (ψ:nat_trans _ _) `T_alg h
    :=
      GenMendlerIteration hsEndC InitialEndC Colims_of_shape_nat_graph_EndC Id_H
                          is_omega_cocont_Id_H' hsEndC X _ isInitial_precomp' HL ψ.


  (** The previous characteristic equation can be split as an equality between coproduct of arrows :
- h ∘ η_T = j_mor
- h ∘ τ_T = τ_M ∘ H h ∘ Θ_T,T

where [η_T, τ_T] : Id + HT --> T
*)

  Local Lemma coprod_iter_eq (h:nat_trans _ _) :
    (∏ x,
     BinCoproductIn1 C (CP (_ (T_mon x)) ((H T_func:functor _ _) (T_mon x))) ·
                     (# L (alg_map Id_H T_alg):nat_trans _ _) x ·
                     h x = j_mor x) ->
    (∏ x,
     BinCoproductIn2 C (CP (_ (T_mon x)) ((H T_func:functor _ _) (T_mon x))) ·
                     (# L (alg_map Id_H T_alg):nat_trans _ _) x · h x =
     (θ (`T_alg ⊗ p T_alg):nat_trans _ _) x · (# H h:nat_trans _ _) x · τ_M x) ->
    # L (alg_map Id_H T_alg) · h = (ψ:nat_trans _ _) `T_alg h.
  Proof.
    intros hB1 hB2.
    eapply (nat_trans_eq hs).
    intros x.
    etrans.
    etrans.
    eapply cancel_postcomposition.
    eapply BinCoproductArrowEta.
    eapply postcompWithBinCoproductArrow.
    eapply BinCoproductArrow_eq.
    - apply hB1.
    - apply hB2.
  Qed.


  Let τT := τ_lmodule_mor T.

  (** j is a morphism of representation.
    It is exactly the 'H' part of the Id + H algebra morphism diagram *)
  Lemma j_mor_rep x : τT x · j_mor x = (# H j_mor:nat_trans _ _) x · τ_M x.
  Proof.
    etrans.
    eapply pathsinv0.
    apply assoc.
    etrans.
    eapply cancel_precomposition.
    apply (nat_trans_eq_pointwise (algebra_mor_commutes _ _ _ j) x).
    etrans.
    apply assoc.
    etrans.
    apply cancel_postcomposition.
    apply BinCoproductIn2Commutes.
    etrans;[eapply pathsinv0; apply assoc|].
    apply cancel_precomposition.
    apply BinCoproductIn2Commutes.
  Qed.

  (** j satisfies the η-related diagram of monad morphism.
         This is Id part of the Id+H-algebra morphism diagram *)
  Lemma j_mon_η :   ∏ a : C, (Monads.η T_mon) a · j_mor a = (Monads.η M) a.
  Proof.
    intro a.
    etrans.
    eapply pathsinv0.
    eapply assoc.
    etrans.
    eapply cancel_precomposition.
    eapply (nat_trans_eq_pointwise (algebra_mor_commutes _ _ _ j) a).
    etrans;[eapply assoc|].
    etrans.
    apply cancel_postcomposition.
    eapply BinCoproductIn1Commutes.
    etrans;[eapply pathsinv0;eapply assoc|].
    etrans.
    apply cancel_precomposition.
    eapply BinCoproductIn1Commutes.
    apply id_left.
  Qed.

  Let j_ptd : precategory_Ptd C hs ⟦ ptd_from_mon hs T_mon, ptd_from_mon hs M⟧.
  Proof.
    mkpair.
    - eapply j.
    - intros x.
      eapply j_mon_η.
  Defined.



  (** j is a monad morphism (following Ralph's proof). For the square diagram,
     we show that both parts satisfies the same Mendler iterator characteristic equation*)
  Lemma j_mon : Monad_Mor_laws (T:=T_mon) (T':=M) (mor_from_algebra_mor _ _ _ j).
  Proof.
    split.
    - apply (nat_trans_eq_pointwise (a:= compose (C:=EndC)  (μ T_mon) j_mor)
                                    (a':= compose(C:=EndC)
                                                 (compose (C:=EndC)
                                                          (a:=_∙_)
                                                          (b:=_∙_)
                                                          (c:=_∙_)
                                                          (j_mor ø T_mon ) (M ∘ j_mor) )
                                                 (μ M))).
      apply (uniqueExists _ _ uniq_iter).
      + apply coprod_iter_eq; intro x.
        * (* T monad law *)
          etrans;[apply assoc|].
          etrans.
          apply cancel_postcomposition.
          eapply (Monad_law1 (T:=T_mon)).
          apply id_left.
        * (* tau_T is a module morphism *)
          etrans;[apply assoc|].
          etrans.
          apply cancel_postcomposition.
          eapply (LModule_Mor_σ _  τT).
          etrans;[eapply pathsinv0;eapply assoc|].
          etrans;[eapply pathsinv0;eapply assoc|].
          etrans; [| eapply assoc].
          apply cancel_precomposition.
          rewrite functor_comp.
          etrans; [| eapply assoc].
          apply cancel_precomposition.
          apply j_mor_rep.
      + apply coprod_iter_eq; intro x.
        * etrans;[apply assoc|].
          etrans.
          eapply cancel_postcomposition.
          etrans;[apply assoc|].
          eapply cancel_postcomposition.
          eapply j_mon_η.
          etrans.
          eapply cancel_postcomposition.
          eapply pathsinv0.
          eapply (nat_trans_ax (Monads.η M )).
          etrans; [|apply id_right].
          rewrite <- assoc.
          eapply cancel_precomposition.
          eapply Monad_law1.
        * etrans;[eapply assoc|].
          etrans;[eapply cancel_postcomposition|].
          etrans;[eapply assoc|].
          etrans;[eapply cancel_postcomposition|].
          apply j_mor_rep.
          rewrite <- assoc.
          eapply cancel_precomposition.
          eapply pathsinv0.
          eapply (nat_trans_ax τ_M).
          etrans.
          repeat rewrite <- assoc.
          eapply cancel_precomposition.
          eapply cancel_precomposition.
          eapply (LModule_Mor_σ _  τ_M ( x)).
          repeat rewrite assoc.
          eapply cancel_postcomposition.
          etrans.
          repeat rewrite <- assoc.
          eapply cancel_precomposition.
          etrans.
          eapply assoc.
          eapply cancel_postcomposition.
          eapply (θ_nat_2_pw _ _ _ j_ptd).
          etrans.
          repeat rewrite assoc.
          eapply cancel_postcomposition.
          eapply cancel_postcomposition.
          eapply (θ_nat_1_pw _ _ j_mor (ptd_from_mon hs T_mon)).
          repeat rewrite <- assoc.
          eapply cancel_precomposition.
          rewrite functor_comp.
          rewrite functor_comp.
          repeat rewrite assoc.
          eapply cancel_postcomposition.
          rewrite <- functor_comp.
          etrans.
          eapply functor_comp_pw.
          apply functor_cancel_pw.
          apply (nat_trans_eq hs).
          intro y.
          etrans.
          eapply cancel_postcomposition.
          etrans.
          eapply cancel_precomposition.
          eapply functor_id.
          eapply id_right.
          apply cancel_precomposition.
          apply id_left.
    - apply j_mon_η.
  Qed.


End InitialRep.
